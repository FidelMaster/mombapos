class AddStockeableToProducts < ActiveRecord::Migration[7.1]
  def change
    add_column :products, :stockeable, :boolean, default: false
  end
end
