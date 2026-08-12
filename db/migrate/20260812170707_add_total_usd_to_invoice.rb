class AddTotalUsdToInvoice < ActiveRecord::Migration[7.1]
  def change
    add_column :invoices, :total_usd, :decimal
  end
end
