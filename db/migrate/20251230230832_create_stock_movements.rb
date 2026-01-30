class CreateStockMovements < ActiveRecord::Migration[7.1]
  def change
    create_table :stock_movements do |t|
      t.references :tenant, null: false, foreign_key: true
      t.references :branch, null: false, foreign_key: true
      t.references :warehouse, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.decimal :quantity
      t.decimal :quantity_before
      t.string :movement_type
      t.string :reference_type
      t.bigint :reference_id

      t.timestamps
    end
  end
end
