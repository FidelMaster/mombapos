class AddPriceListToInvoices < ActiveRecord::Migration[7.1]
  def change
    add_reference :invoices, :price_list, null: true, foreign_key: true
  end
end
