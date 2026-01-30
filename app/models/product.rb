class Product < ApplicationRecord
  belongs_to :tenant
  belongs_to :supplier
  belongs_to :product_category
  belongs_to :stock_unit_measure, class_name: "UnitMeasure"
  belongs_to :sale_unit_measure, class_name: "UnitMeasure"

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

  default_scope { where(tenant_id: Current.tenant.id) }

  validates :tenant, presence: true
  validates :product_type, presence: true

  after_save :sync_price_to_default_list
  before_save :set_stockeable

  private

  def set_stockeable
    self.stockeable = raw_material? || finished_product?
  end

  def sync_price_to_default_list
    return unless price.present? && price_changed?

    # Find the default active price list for this tenant
    default_list = PriceList.where(tenant_id: tenant_id, is_active: true).first
    return unless default_list

    # Find or create the line item in that list
    item = price_list_items.find_or_initialize_by(price_list: default_list)
    item.price = price
    item.save
  end
end
