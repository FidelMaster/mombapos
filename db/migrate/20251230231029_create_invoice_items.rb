class CreateInvoiceItems < ActiveRecord::Migration[7.1]
  def change
    create_table :invoice_items do |t|
      t.references :invoice, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.references :unit_measure, null: false, foreign_key: true
      t.decimal :quantity
      t.decimal :unit_price
      t.decimal :subtotal
      t.decimal :tax_amount
      t.decimal :total

      t.timestamps
    end
  end
end
