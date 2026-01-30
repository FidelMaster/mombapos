class CreateProducts < ActiveRecord::Migration[7.1]
  def change
    create_table :products do |t|
      t.references :tenant, null: false, foreign_key: true
      t.string :product_code
      t.string :name
      t.text :description
      t.string :product_type
      t.references :product_category, null: false, foreign_key: true
      t.decimal :cost
      t.references :stock_unit_measure, null: false, foreign_key: true
      t.references :sale_unit_measure, null: false, foreign_key: { to_table: :stock_unit_measures }
      t.boolean :is_active

      t.timestamps
    end
  end
end
