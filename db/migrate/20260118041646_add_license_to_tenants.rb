class AddLicenseToTenants < ActiveRecord::Migration[7.1]
  def change
    add_reference :tenants, :license, null: true, foreign_key: true
  end
end
