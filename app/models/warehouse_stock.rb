class WarehouseStock < ApplicationRecord
  belongs_to :warehouse
  belongs_to :product

  # Sync product total quantity whenever warehouse stock changes
  after_save :sync_product_quantity
  after_destroy :sync_product_quantity

  private

  def sync_product_quantity
    # Recalculate total product quantity from all warehouse stocks
    total = product.warehouse_stocks.sum(:stock_available)
    product.update_column(:quantity, total)
  end
end
