class AddNoteToInvoice < ActiveRecord::Migration[7.1]
  def change
    add_column :invoices, :notes, :text
  end
end
