class AllowNullOnBankAccountIdInInvoicePayment < ActiveRecord::Migration[7.1]
  def change
    change_column_null :invoice_payments, :bank_account_id, true
  end
end
