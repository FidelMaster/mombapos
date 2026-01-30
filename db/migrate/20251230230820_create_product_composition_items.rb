class CreateProductCompositionItems < ActiveRecord::Migration[7.1]
  def change
    create_table :product_composition_items do |t|
      t.references :product_composition, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.decimal :quantity
      t.references :unit_measure, null: false, foreign_key: true

      t.timestamps
    end
  end
end
