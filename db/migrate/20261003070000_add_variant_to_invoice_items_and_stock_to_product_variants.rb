class AddVariantToInvoiceItemsAndStockToProductVariants < ActiveRecord::Migration[7.1]
  def change
    add_reference :invoice_items, :product_variant, foreign_key: true, null: true
    add_column :product_variants, :stock_quantity, :decimal, precision: 10, scale: 2, default: 0.0, null: false
  end
end
