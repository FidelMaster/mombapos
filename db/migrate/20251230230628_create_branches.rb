class CreateBranches < ActiveRecord::Migration[7.1]
  def change
    create_table :branches do |t|
      t.references :tenant, null: false, foreign_key: true
      t.string :name
      t.boolean :is_default
      t.boolean :is_active

      t.timestamps
    end
  end
end
