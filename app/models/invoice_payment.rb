class InvoicePayment < ApplicationRecord
  belongs_to :invoice
  belongs_to :payment_method
  belongs_to :bank_account, optional: true
end
