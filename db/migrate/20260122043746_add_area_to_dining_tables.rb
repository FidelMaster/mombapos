class AddAreaToDiningTables < ActiveRecord::Migration[7.1]
  def change
    add_reference :dining_tables, :area, null: true, foreign_key: true
  end
end
