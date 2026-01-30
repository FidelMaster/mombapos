class CreateCustomerAddresses < ActiveRecord::Migration[7.1]
  def change
    create_table :customer_addresses do |t|
      t.references :customer, null: false, foreign_key: true
      t.string :address
      t.references :department, null: false, foreign_key: true
      t.references :municipality, null: false, foreign_key: true
      t.boolean :is_default

      t.timestamps
    end
  end
end
