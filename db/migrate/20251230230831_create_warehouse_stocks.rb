class CreateWarehouseStocks < ActiveRecord::Migration[7.1]
  def change
    create_table :warehouse_stocks do |t|
      t.references :warehouse, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.decimal :stock_available
      t.decimal :stock_reserved

      t.timestamps
    end
  end
end
