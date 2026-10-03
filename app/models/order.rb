class Order < ApplicationRecord
  # ---------------------------------------------------------------------------
  # Estados
  # ---------------------------------------------------------------------------
  # `open` / `closed` se conservan para el POS de restaurante (comandas).
  # El flujo de pedidos de joyería (vitrina / taller) usa WORKFLOW_STATUSES.
  POS_STATUSES      = %w[open closed].freeze
  WORKFLOW_STATUSES = %w[draft pending_deposit in_workshop ready_for_pickup completed cancelled].freeze
  ACTIVE_WORKFLOW_STATUSES = %w[draft pending_deposit in_workshop ready_for_pickup].freeze

  # Estados en los que se pueden registrar anticipos / abonos.
  ADVANCE_ALLOWED_STATUSES = %w[draft pending_deposit in_workshop ready_for_pickup].freeze

  # Estados desde los que, al recibir un anticipo, la orden pasa a taller.
  AUTO_WORKSHOP_STATUSES = %w[draft pending_deposit].freeze

  # Máquina de estados: estado actual => estados destino permitidos.
  TRANSITIONS = {
    "draft"            => %w[pending_deposit cancelled],
    "pending_deposit"  => %w[in_workshop draft cancelled],
    "in_workshop"      => %w[ready_for_pickup cancelled],
    "ready_for_pickup" => %w[completed in_workshop cancelled],
    "completed"        => [],
    "cancelled"        => []
  }.freeze

  STATUS_LABELS = {
    "open"             => "Abierta",
    "closed"           => "Cerrada",
    "draft"            => "Borrador / Cotización",
    "pending_deposit"  => "Esperando anticipo",
    "in_workshop"      => "En taller",
    "ready_for_pickup" => "Listo para entrega",
    "completed"        => "Entregado",
    "cancelled"        => "Cancelado"
  }.freeze

  KIND_LABELS = {
    "standard"     => "Vitrina",
    "custom_order" => "Taller / Encargo"
  }.freeze

  enum status: {
    open: "open",
    closed: "closed",
    draft: "draft",
    pending_deposit: "pending_deposit",
    in_workshop: "in_workshop",
    ready_for_pickup: "ready_for_pickup",
    completed: "completed",
    cancelled: "cancelled"
  }

  enum order_type: {
    dine_in: 0,
    delivery: 1,
    pickup: 2
  }

  enum order_kind: {
    standard: "standard",          # Stock de vitrina
    custom_order: "custom_order"   # Encargo / taller
  }

  # ---------------------------------------------------------------------------
  # Asociaciones
  # ---------------------------------------------------------------------------
  belongs_to :tenant
  belongs_to :dining_table, optional: true
  belongs_to :customer

  has_many :order_items, dependent: :destroy
  has_many :order_advances, -> { order(payment_date: :desc, id: :desc) }, dependent: :restrict_with_error
  has_one :invoice, dependent: :nullify
  accepts_nested_attributes_for :order_items, allow_destroy: true,
                                reject_if: ->(attrs) { attrs["id"].blank? && attrs["product_id"].blank? && attrs["product_variant_id"].blank? }

  default_scope { where(tenant_id: Current.tenant.id) }

  scope :workflow, -> { where(status: WORKFLOW_STATUSES) }
  scope :active_workflow, -> { where(status: ACTIVE_WORKFLOW_STATUSES) }
  scope :overdue, -> { active_workflow.where("promised_delivery_date < ?", Date.current) }

  # ---------------------------------------------------------------------------
  # Callbacks
  # ---------------------------------------------------------------------------
  before_validation :set_defaults, on: :create
  before_validation :calculate_totals
  before_save :calculate_totals

  # ---------------------------------------------------------------------------
  # Validaciones (solo aplican al flujo de pedidos; el POS no se ve afectado)
  # ---------------------------------------------------------------------------
  with_options if: :workflow? do
    validate :must_have_items
    validates :promised_delivery_date, presence: true, if: :requires_delivery_date?
    validate :promised_date_not_in_past, if: :will_save_change_to_promised_delivery_date?
    validate :total_covers_advances
    validate :fully_paid_to_complete, if: -> { will_save_change_to_status?(to: "completed") }
  end

  # ---------------------------------------------------------------------------
  # API pública
  # ---------------------------------------------------------------------------
  def self.status_label(value) = STATUS_LABELS.fetch(value.to_s, value.to_s.humanize)
  def self.kind_label(value)   = KIND_LABELS.fetch(value.to_s, value.to_s.humanize)

  def status_label = self.class.status_label(status)
  def kind_label   = self.class.kind_label(order_kind)

  def workflow?
    WORKFLOW_STATUSES.include?(status)
  end

  def editable?
    ACTIVE_WORKFLOW_STATUSES.include?(status)
  end

  def accepts_advances?
    ADVANCE_ALLOWED_STATUSES.include?(status) && balance_amount.to_d.positive?
  end

  def overdue?
    promised_delivery_date.present? && promised_delivery_date < Date.current &&
      ACTIVE_WORKFLOW_STATUSES.include?(status)
  end

  def paid_percentage
    return 0 if total.to_d.zero?

    ((advance_amount.to_d / total.to_d) * 100).round.clamp(0, 100)
  end

  def available_transitions
    TRANSITIONS.fetch(status, [])
  end

  def can_transition_to?(new_status)
    available_transitions.include?(new_status.to_s)
  end

  # Cambia de fase validando la máquina de estados. Devuelve true/false.
  def transition_to(new_status)
    new_status = new_status.to_s

    unless can_transition_to?(new_status)
      errors.add(:status, "no puede pasar de «#{status_label}» a «#{self.class.status_label(new_status)}»")
      return false
    end

    self.status = new_status
    save
  end

  # Recalcula anticipos/saldo desde la BD y aplica la transición automática
  # (pending_deposit → in_workshop). Lo invoca OrderAdvance tras crear/eliminar.
  def refresh_balances!
    paid = order_advances.unscope(:order).sum(:amount).to_d
    new_status = status

    if paid.positive? && AUTO_WORKSHOP_STATUSES.include?(status)
      new_status = "in_workshop"
    end

    update_columns(
      advance_amount: paid,
      balance_amount: total.to_d - paid,
      status: new_status,
      updated_at: Time.current
    )
  end

  private

  def set_defaults
    self.tenant_id ||= Current.tenant&.id
    self.status ||= :open
    self.order_code ||= "ORD-#{SecureRandom.hex(4).upcase}"
    self.customer_name ||= customer&.name if customer
  end

  # total = suma de ítems vivos; balance = total - anticipos.
  def calculate_totals
    live_items = order_items.reject(&:marked_for_destruction?)

    self.total_items = live_items.sum { |item| item.quantity.to_d }.to_i
    self.total = live_items.sum { |item| item.quantity.to_d * (item.unit_price || item.product_variant&.price || item.product&.price).to_d }
    self.advance_amount ||= 0
    self.balance_amount = total.to_d - advance_amount.to_d
  end

  def requires_delivery_date?
    custom_order? && !draft? && !cancelled?
  end

  def must_have_items
    return if order_items.reject(&:marked_for_destruction?).any?

    errors.add(:base, "Agrega al menos una pieza al pedido")
  end

  def promised_date_not_in_past
    return if promised_delivery_date.blank? || promised_delivery_date >= Date.current

    errors.add(:promised_delivery_date, "no puede ser una fecha pasada")
  end

  def total_covers_advances
    return if total.to_d >= advance_amount.to_d

    errors.add(:base, "El total del pedido no puede ser menor a lo ya abonado (#{advance_amount.to_d.round(2)})")
  end

  def fully_paid_to_complete
    return if balance_amount.to_d <= 0

    errors.add(:status, "no se puede marcar como entregado: hay un saldo pendiente de #{balance_amount.to_d.round(2)}")
  end
end
