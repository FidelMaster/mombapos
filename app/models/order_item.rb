class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :product
  belongs_to :product_variant, optional: true

  validates :quantity, numericality: { greater_than: 0 }
  validates :unit_price, numericality: { greater_than_or_equal_to: 0 }
  validates :engraving_text, length: { maximum: 120 }
  validate  :variant_matches_product

  before_validation :sync_product_from_variant
  before_validation :calculate_subtotal

  def customized?
    engraving_text.present? || custom_specifications.present?
  end

  def display_name
    [product&.name, product_variant&.variant_name].compact_blank.join(" — ")
  end

  private

  # Si se elige una variante, su producto base manda y su precio es el sugerido.
  def sync_product_from_variant
    return unless product_variant

    self.product_id = product_variant.product_id if product_id.blank?
    self.unit_price = product_variant.price if unit_price.blank?
  end

  def calculate_subtotal
    self.unit_price ||= product&.price
    self.subtotal = (quantity || 0) * (unit_price || 0)
  end

  def variant_matches_product
    return unless product_variant && product_id

    errors.add(:product_variant, "no corresponde al producto seleccionado") if product_variant.product_id != product_id
  end
end
