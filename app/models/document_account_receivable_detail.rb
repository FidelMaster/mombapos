class DocumentAccountReceivableDetail < ApplicationRecord
  self.table_name = "account_receivable_details" # Mapping specifically if we don't rename table yet, but I'll rename the table too if I can.
  
  belongs_to :document_account_receivable

  enum movement_type: {
    debit: "debit",
    credit: "credit"
  }

  enum document_type: {
    invoice: "invoice",
    receipt: "receipt",
    credit_note: "credit_note"
  }

  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :movement_type, :document_type, :date, presence: true
end
