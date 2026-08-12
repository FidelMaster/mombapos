class AddTotalUsdToInvoiceItem < ActiveRecord::Migration[7.1]
  def change
    add_column :invoice_items, :total_usd, :decimal
  end
end
