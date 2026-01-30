class CreateOrders < ActiveRecord::Migration[7.1]
  def change
    create_table :orders do |t|
      t.references :tenant, null: false, foreign_key: true
      t.string :order_code
      t.references :dining_table, null: false, foreign_key: true
      t.references :customer, null: false, foreign_key: true
      t.string :customer_name
      t.string :status, null: false, default: "open"
      t.integer :total_items, null: false, default: 0
      t.decimal :total, null: false, default: 0

      t.timestamps
    end
  end
end
