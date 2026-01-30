class AddTenantAndRoleToUsers < ActiveRecord::Migration[7.1]
  def change
    add_reference :users, :tenant, null: false, foreign_key: true
    add_column :users, :role, :integer, default: 0, null: false
    add_column :users, :is_active, :boolean, default: true
  end
end
