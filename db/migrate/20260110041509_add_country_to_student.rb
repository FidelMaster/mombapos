class AddCountryToStudent < ActiveRecord::Migration[7.1]
  def change
    add_reference :students, :country, null: false, foreign_key: true
  end
end
