class AddDocumentAccountReceivableToReceipts < ActiveRecord::Migration[7.1]
  def change
    add_reference :receipts, :document_account_receivable, null: false, foreign_key: true
  end
end
