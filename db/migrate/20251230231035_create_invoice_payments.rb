class CreateInvoicePayments < ActiveRecord::Migration[7.1]
  def change
    create_table :invoice_payments do |t|
      t.references :invoice, null: false, foreign_key: true
      t.references :payment_method, null: false, foreign_key: true
      t.references :bank_account, null: false, foreign_key: true
      t.string :currency
      t.decimal :exchange_rate
      t.decimal :amount
      t.datetime :paid_at

      t.timestamps
    end
  end
end
