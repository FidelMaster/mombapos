class StockMovement < ApplicationRecord
  belongs_to :tenant
  belongs_to :branch
  belongs_to :warehouse
  belongs_to :product

  default_scope { where(tenant_id: Current.tenant.id) }

  validates :tenant, presence: true

  validates :warehouse, :product, :quantity, :movement_type, presence: true
  
  before_create :set_quantity_before
  after_create :update_warehouse_stock

  private

  def set_quantity_before
    stock = WarehouseStock.find_by(warehouse: warehouse, product: product)
    self.quantity_before = stock&.stock_available || 0
  end

  def update_warehouse_stock
    stock = WarehouseStock.find_or_initialize_by(warehouse: warehouse, product: product)
    stock.stock_available ||= 0
    
    if movement_type == "in"
      stock.stock_available += quantity
    elsif movement_type == "out"
      stock.stock_available -= quantity
    end
    
    stock.save!
  end
end
