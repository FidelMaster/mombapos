class ProductCompositionItem < ApplicationRecord
  belongs_to :product_composition
  belongs_to :product
  belongs_to :unit_measure

  def subtotal_stock_reduction(parent_quantity)
    quantity * parent_quantity
  end
end
