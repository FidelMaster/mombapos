class CreateCustomers < ActiveRecord::Migration[7.1]
  def change
    create_table :customers do |t|
      t.references :tenant, null: false, foreign_key: true
      t.string :name
      t.string :tax_id
      t.string :address
      t.references :municipality, null: false, foreign_key: true
      t.string :contact_name
      t.string :contact_email
      t.string :contact_phone
      t.decimal :credit_limit
      t.boolean :is_tax_exempt
      t.boolean :is_active

      t.timestamps
    end
  end
end
