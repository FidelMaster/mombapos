class Receipt < ApplicationRecord
  belongs_to :customer
  belongs_to :tenant
  belongs_to :document_account_receivable, optional: true # Optional if we want global payments, but better targeted

  default_scope { where(tenant_id: Current.tenant.id) }

  validates :total_amount, presence: true, numericality: { greater_than: 0 }
  validates :payment_method, :receipt_date, presence: true

  after_create :register_ar_movement

  private

  def register_ar_movement
    # If a specific document was selected, pay that. 
    # Otherwise, we could implement logic to pay the oldest ones (FIFO).
    # For simplicity as requested:
    
    target_ar = document_account_receivable
    
    # If no targeted AR, find the one with the highest balance or oldest for the customer
    target_ar ||= customer.document_account_receivables.joins(:document_account_receivable_details)
                          .group('document_account_receivables.id')
                          .having('SUM(CASE WHEN account_receivable_details.movement_type = \'debit\' THEN account_receivable_details.amount ELSE -account_receivable_details.amount END) > 0')
                          .first

    return unless target_ar

    target_ar.document_account_receivable_details.create!(
      document_type: :receipt,
      document_id: id,
      movement_type: :credit, # Payment decreases balance
      amount: total_amount,
      date: receipt_date
    )
  end
end
