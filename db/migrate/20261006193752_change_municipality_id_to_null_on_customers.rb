class ChangeMunicipalityIdToNullOnCustomers < ActiveRecord::Migration[7.1]
  def change
    change_column_null :customers, :municipality_id, true 
  end
end
