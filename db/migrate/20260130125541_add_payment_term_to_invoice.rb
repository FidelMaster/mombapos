class AddPaymentTermToInvoice < ActiveRecord::Migration[7.1]
  def change
    add_reference :invoices, :payment_term, null: true, foreign_key: true
    add_column :invoices, :issue_date, :date
    add_column :invoices, :due_date, :date
  end
end
