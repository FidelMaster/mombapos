class AddCountryToDepartment < ActiveRecord::Migration[7.1]
  def change
    add_column :departments, :country_id, :integer
    add_foreign_key :departments, :countries
  end
end
