class AddTenantToBankAccount < ActiveRecord::Migration[7.1]
  def change
    add_reference :bank_accounts, :tenant, null: true, foreign_key: true
  end
end
