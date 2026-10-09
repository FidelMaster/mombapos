class AddBusinessDniToTenants < ActiveRecord::Migration[7.1]
  def change
    #optional
    add_column :tenants, :business_dni, :string, null: true
  end
end
