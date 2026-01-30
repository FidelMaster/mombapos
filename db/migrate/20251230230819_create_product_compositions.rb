class CreateProductCompositions < ActiveRecord::Migration[7.1]
  def change
    create_table :product_compositions do |t|
      t.references :tenant, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.string :name

      t.timestamps
    end
  end
end
