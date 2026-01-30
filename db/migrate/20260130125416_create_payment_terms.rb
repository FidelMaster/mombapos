class CreatePaymentTerms < ActiveRecord::Migration[7.1]
  def change
    create_table :payment_terms do |t|
      t.string :name
      t.decimal :total, default: 0
      t.text :description
      t.boolean :is_active, default: true
      t.decimal :grace_days, default: 0
      t.decimal :early_payment_discount, default: 0
      t.decimal :late_fee_percentage, default: 0

      t.timestamps
    end
  end
end
