class CreateReceipts < ActiveRecord::Migration[7.1]
  def change
    create_table :receipts do |t|
      t.references :customer, null: false, foreign_key: true
      t.date :receipt_date
      t.decimal :total_amount, default: 0
      t.string :payment_method
      t.string :reference
      t.references :tenant, null: false, foreign_key: true

      t.timestamps
    end
  end
end
