class OrderAdvance < ApplicationRecord
  # Métodos de pago que requieren cuenta bancaria destino y referencia.
  BANK_PAYMENT_CODES = %w[TRANSFER].freeze

  belongs_to :tenant
  belongs_to :order
  belongs_to :payment_method
  belongs_to :bank_account, optional: true
  belongs_to :received_by, class_name: "User", optional: true

  default_scope { where(tenant_id: Current.tenant&.id) }

  before_validation :set_defaults, on: :create

  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :exchange_rate, numericality: { greater_than: 0 }, allow_nil: true
  validates :payment_date, presence: true
  validates :bank_account, presence: true, if: :requires_bank_account?
  validate  :order_accepts_advances, on: :create
  validate  :does_not_exceed_order_total
  validate  :same_tenant_as_order

  # Mantener saldos de la orden sincronizados (dentro de la misma transacción).
  after_save    :refresh_order_balances
  after_destroy :refresh_order_balances

  def requires_bank_account?
    BANK_PAYMENT_CODES.include?(payment_method&.code)
  end

  private

  def set_defaults
    self.tenant_id      ||= order&.tenant_id || Current.tenant&.id
    self.received_by_id ||= Current.user&.id
    self.payment_date   ||= Time.current
    self.exchange_rate  ||= 1.0
  end

  def order_accepts_advances
    return if order.nil?
    return if Order::ADVANCE_ALLOWED_STATUSES.include?(order.status)

    errors.add(:base, "No se pueden registrar abonos en un pedido «#{order.status_label}»")
  end

  # El acumulado de anticipos no puede superar el total de la orden.
  def does_not_exceed_order_total
    return if order.nil? || amount.blank?

    already_paid = order.order_advances.unscope(:order).where.not(id: id).sum(:amount).to_d
    remaining    = order.total.to_d - already_paid
    return if amount.to_d <= remaining

    errors.add(:amount, "excede el saldo pendiente del pedido (máximo #{remaining.round(2)})")
  end

  def same_tenant_as_order
    return if order.nil? || tenant_id == order.tenant_id

    errors.add(:order, "no pertenece a la empresa actual")
  end

  def refresh_order_balances
    order.refresh_balances!
  end
end
