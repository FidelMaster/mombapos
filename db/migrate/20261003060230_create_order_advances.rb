class CreateOrderAdvances < ActiveRecord::Migration[7.1]
  def change
    create_table :order_advances do |t|
      t.references :tenant,         null: false, foreign_key: true
      t.references :order,          null: false, foreign_key: true
      t.references :payment_method, null: false, foreign_key: true
      t.references :bank_account,   null: true,  foreign_key: true
      t.references :received_by,    null: true,  foreign_key: { to_table: :users }

      t.decimal  :amount,        precision: 12, scale: 2, null: false
      t.decimal  :exchange_rate, precision: 10, scale: 4, default: 1.0
      t.string   :reference_number
      t.datetime :payment_date, null: false
      t.text     :notes

      t.timestamps
    end

    add_index :order_advances, %i[tenant_id payment_date]
    add_check_constraint :order_advances, "amount > 0", name: "order_advances_amount_positive"
  end
end
