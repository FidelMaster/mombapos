class CreatePriceListItems < ActiveRecord::Migration[7.1]
  def change
    create_table :price_list_items do |t|
      t.references :price_list, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.decimal :price
      t.boolean :includes_tax

      t.timestamps
    end
  end
end
