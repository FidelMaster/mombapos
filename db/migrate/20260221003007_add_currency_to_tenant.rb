class AddCurrencyToTenant < ActiveRecord::Migration[7.1]
  def change
    add_reference :tenants, :currency, null: true, foreign_key: true
  end
end
