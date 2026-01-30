class CreateResources < ActiveRecord::Migration[7.1]
  def change
    create_table :resources do |t|
      t.references :tenant, null: false, foreign_key: true
      t.references :level, null: false, foreign_key: true
      t.string :name
      t.string :resource_type
      t.string :location_url
      t.boolean :is_active

      t.timestamps
    end
  end
end
