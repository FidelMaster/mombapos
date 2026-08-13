class Product < ApplicationRecord
  belongs_to :tenant
  belongs_to :supplier, optional: true
  belongs_to :product_category
  belongs_to :stock_unit_measure, class_name: "UnitMeasure", optional: true
  belongs_to :sale_unit_measure, class_name: "UnitMeasure", optional: true

  has_many :warehouse_stocks, dependent: :destroy
  has_many :price_list_items, dependent: :destroy
  has_one :product_composition, dependent: :destroy

  accepts_nested_attributes_for :warehouse_stocks, allow_destroy: true
  accepts_nested_attributes_for :price_list_items, allow_destroy: true

  enum product_type: {
    raw_material: "M",
    finished_product: "T",
    service: "S",
    consumable: "C",
    kit: "K"
  }

  default_scope { where(tenant_id: Current.tenant&.id) }

  scope :stockables, -> {
    where.not(product_type: [
      product_types[:service],
      product_types[:kit]
    ])
  }

  validates :tenant, presence: true
  validates :product_type, presence: true

  # Callbacks
  before_save :set_stockeable
  before_save :sync_total_quantity
  after_save :sync_price_to_default_list

  def name_with_code
    "#{product_code} - #{name}" 
  end

  private

  def set_stockeable
    self.stockeable = raw_material? || finished_product? || consumable?
  end

  def sync_total_quantity
    # Recorre los registros de warehouse_stocks (incluyendo los que vienen del formulario en memoria)
    # y suma el stock disponible. Si no hay registros o viene nil, asigna 0.
    self.quantity = warehouse_stocks.reject(&:marked_for_destruction?).sum { |ws| ws.stock_available.to_f }
  end

  def sync_price_to_default_list
    return unless price.present? && saved_change_to_price?

    # Buscar la lista de precios por defecto
    default_list = PriceList.find_by(tenant_id: tenant_id, is_active: true)
    return unless default_list

    # Crear o actualizar el ítem en la lista
    item = price_list_items.find_or_initialize_by(price_list: default_list)
    item.price = price
    item.save
  end
end