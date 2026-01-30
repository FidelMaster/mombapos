class CreateLevels < ActiveRecord::Migration[7.1]
  def change
    create_table :levels do |t|
      t.references :tenant, null: false, foreign_key: true
      t.string :name
      t.integer :order
      t.boolean :is_active

      t.timestamps
    end
  end
end
