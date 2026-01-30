class InvoiceItem < ApplicationRecord
  belongs_to :invoice
  belongs_to :product
  belongs_to :unit_measure

  before_validation :set_defaults

  private
    def set_defaults
      self.unit_measure ||= product&.sale_unit_measure
      self.subtotal ||= (quantity.to_f * unit_price.to_f)
      self.tax_amount ||= 0 # Calculate if needed
      self.total ||= self.subtotal + self.tax_amount
    end
end
