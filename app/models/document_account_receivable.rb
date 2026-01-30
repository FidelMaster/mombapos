class DocumentAccountReceivable < ApplicationRecord
  belongs_to :tenant
  belongs_to :customer
  belongs_to :payment_term
  
  # For polymorphism if needed, but the prompt structure shows direct document_id/type
  belongs_to :document, polymorphic: true, optional: true

  has_many :document_account_receivable_details, dependent: :destroy

  validates :customer, presence: true

  # Short term simple balance calculation
  def balance
    debits = document_account_receivable_details.where(movement_type: :debit).sum(:amount)
    credits = document_account_receivable_details.where(movement_type: :credit).sum(:amount)
    debits - credits
  end
end
