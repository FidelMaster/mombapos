class CreateAccountReceivableDetails < ActiveRecord::Migration[7.1]
  def change
    create_table :account_receivable_details do |t|
      t.references :document_account_receivable, null: false, foreign_key: true
      t.string :document_type
      t.integer :document_id
      t.string :document_number
      t.decimal :amount
      t.decimal :amount_in_usd
      t.decimal :exchange_rate
      t.string :movement_type
      t.date :date

      t.timestamps
    end
  end
end
