class CreatePriceLists < ActiveRecord::Migration[7.1]
  def change
    create_table :price_lists do |t|
      t.references :tenant, null: false, foreign_key: true
      t.string :name
      t.string :currency
      t.boolean :is_active

      t.timestamps
    end
  end
end
