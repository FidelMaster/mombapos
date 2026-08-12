class AddDescriptionToInvoiceItem < ActiveRecord::Migration[7.1]
  def change
    add_column :invoice_items, :description, :string
  end
end
