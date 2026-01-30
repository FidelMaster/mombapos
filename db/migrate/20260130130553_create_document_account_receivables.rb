class CreateDocumentAccountReceivables < ActiveRecord::Migration[7.1]
  def change
    create_table :document_account_receivables do |t|
      t.references :tenant, null: false, foreign_key: true
     
      t.references :payment_term, null: false, foreign_key: true
      t.references :customer, null: false, foreign_key: true
      t.integer :document_id, null: false
      t.string :document_number, default: ""
      t.string :document_reference_number, default: ""
      t.string :document_type, default: ""
      t.text :description, default: ""
      t.decimal :amount, default: 0
      t.decimal :amount_in_usd, default: 0
      t.decimal :balance, default: 0
      t.decimal :balance_in_usd, default: 0
      t.date :date
    
      t.timestamps
    end
  end
end
