class CreateExchangeRates < ActiveRecord::Migration[7.1]
  def change
    create_table :exchange_rates do |t|
      t.string :currency
      t.decimal :rate
      t.date :effective_date

      t.timestamps
    end
  end
end
