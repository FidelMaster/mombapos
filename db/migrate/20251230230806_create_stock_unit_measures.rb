class CreateStockUnitMeasures < ActiveRecord::Migration[7.1]
  def change
    create_table :stock_unit_measures do |t|
      t.references :tenant, null: false, foreign_key: true
      t.string :name
      t.boolean :is_active

      t.timestamps
    end
  end
end
