class CreateBankAccounts < ActiveRecord::Migration[7.1]
  def change
    create_table :bank_accounts do |t|
      t.references :bank, null: false, foreign_key: true
      t.string :account_number
      t.string :account_name
      t.string :currency

      t.timestamps
    end
  end
end
