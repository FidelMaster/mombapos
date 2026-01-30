class AddMinQuantityIdOnWarehouseStock < ActiveRecord::Migration[7.1]
  def change
    add_column :warehouse_stocks, :min_quantity, :decimal
  end
end
