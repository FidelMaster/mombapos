class AddCountryToStudent < ActiveRecord::Migration[7.1]
  def change
    add_reference :students, :country, null: false, foreign_key: true
    add_foreign_key :students, :countries
  end
end
