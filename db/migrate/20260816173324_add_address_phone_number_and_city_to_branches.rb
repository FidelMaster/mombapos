class AddAddressPhoneNumberAndCityToBranches < ActiveRecord::Migration[7.1]
  def change
    add_column :branches, :address, :string
    add_column :branches, :phone_number, :string
    add_column :branches, :city, :string
  end
end
