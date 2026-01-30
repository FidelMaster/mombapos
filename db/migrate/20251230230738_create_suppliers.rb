class CreateSuppliers < ActiveRecord::Migration[7.1]
  def change
    create_table :suppliers do |t|
      t.references :tenant, null: false, foreign_key: true
      t.string :name
      t.string :contact_name
      t.string :contact_email
      t.string :contact_phone
      t.boolean :is_active

      t.timestamps
    end
  end
end
