class AddEmailToTenant < ActiveRecord::Migration[7.1]
  def change
    add_column :tenants, :email, :string
  end
end
