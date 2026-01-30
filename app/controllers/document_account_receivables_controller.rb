class DocumentAccountReceivablesController < ApplicationController
  def index
    # Calculating balances on the fly as requested
    @customers = Customer.left_outer_joins(document_account_receivables: :document_account_receivable_details)
                         .select('customers.*, 
                                  SUM(CASE WHEN account_receivable_details.movement_type = \'debit\' THEN account_receivable_details.amount ELSE 0 END) as total_debit, 
                                  SUM(CASE WHEN account_receivable_details.movement_type = \'credit\' THEN account_receivable_details.amount ELSE 0 END) as total_credit')
                         .group('customers.id')
                         .having('SUM(CASE WHEN account_receivable_details.movement_type = \'debit\' THEN account_receivable_details.amount ELSE 0 END) > 0 OR SUM(CASE WHEN account_receivable_details.movement_type = \'credit\' THEN account_receivable_details.amount ELSE 0 END) > 0')
  end

  def show
    @customer = Customer.find(params[:id])
    @movements = DocumentAccountReceivableDetail.joins(:document_account_receivable)
                                                 .where(document_account_receivables: { customer_id: @customer.id })
                                                 .order(date: :asc, created_at: :asc)
  end
end
