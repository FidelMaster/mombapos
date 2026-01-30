class AddTenantToAreas < ActiveRecord::Migration[7.1]
  def change
    add_reference :areas, :tenant, null: false, foreign_key: true
  end
end
