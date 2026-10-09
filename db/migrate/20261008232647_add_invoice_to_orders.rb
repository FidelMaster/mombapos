class AddInvoiceToOrders < ActiveRecord::Migration[7.1]
  def change
    add_reference :orders, :invoice, null: true, foreign_key: true
  end
end
