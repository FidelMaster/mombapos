class AddAddressPhoneAndCityToTenants < ActiveRecord::Migration[7.1]
  def change
    add_column :tenants, :address, :string
    add_column :tenants, :phone, :string
    add_column :tenants, :city, :string
  end
end
