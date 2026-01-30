class CreateInvoices < ActiveRecord::Migration[7.1]
  def change
    create_table :invoices do |t|
      t.references :tenant, null: false, foreign_key: true
      t.references :customer, null: false, foreign_key: true
      t.string :invoice_number
      t.date :invoice_date
      t.references :branch, null: false, foreign_key: true
      t.references :warehouse, null: false, foreign_key: true
      t.string :customer_name_snapshot
      t.string :customer_tax_id_snapshot
      t.string :invoice_type
      t.string :status
      t.decimal :exchange_rate
      t.decimal :total_items
      t.decimal :subtotal_amount
      t.decimal :tax_amount
      t.decimal :total_local_amount
      t.decimal :total_foreign_amount
      t.bigint :issued_by
      t.bigint :annulled_by
      t.datetime :annulled_at
      t.string :annulment_reason

      t.timestamps
    end
  end
end
