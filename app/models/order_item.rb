class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :product

  before_validation :calculate_subtotal

  private

  def calculate_subtotal
    self.unit_price ||= product&.price
    self.subtotal = (quantity || 0) * (unit_price || 0)
  end
end
