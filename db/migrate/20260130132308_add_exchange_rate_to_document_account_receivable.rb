class AddExchangeRateToDocumentAccountReceivable < ActiveRecord::Migration[7.1]
  def change
    add_column :document_account_receivables, :exchange_rate, :decimal
  end
end
