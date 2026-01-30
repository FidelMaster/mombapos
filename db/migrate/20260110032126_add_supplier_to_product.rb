class AddSupplierToProduct < ActiveRecord::Migration[7.1]
  def change
    add_column :products, :supplier_id, :bigint
    add_index :products, :supplier_id
    add_foreign_key :products, :suppliers
  end
end
