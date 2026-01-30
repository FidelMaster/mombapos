class AddPriceAndQuantityToProduct < ActiveRecord::Migration[7.1]
  def change
    add_column :products, :price, :decimal
    add_column :products, :quantity, :decimal
  end
end
