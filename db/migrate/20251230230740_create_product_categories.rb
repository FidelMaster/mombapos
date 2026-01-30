class CreateProductCategories < ActiveRecord::Migration[7.1]
  def change
    create_table :product_categories do |t|
      t.references :tenant, null: false, foreign_key: true
      t.string :name
      t.boolean :is_active

      t.timestamps
    end
  end
end
