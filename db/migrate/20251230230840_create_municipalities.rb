class CreateMunicipalities < ActiveRecord::Migration[7.1]
  def change
    create_table :municipalities do |t|
      t.references :department, null: false, foreign_key: true
      t.string :name
      t.boolean :is_active

      t.timestamps
    end
  end
end
