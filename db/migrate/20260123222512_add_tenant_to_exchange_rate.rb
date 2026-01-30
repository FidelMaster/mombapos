class AddTenantToExchangeRate < ActiveRecord::Migration[7.1]
  def change
    add_reference :exchange_rates, :tenant, null: true, foreign_key: true
  end
end
