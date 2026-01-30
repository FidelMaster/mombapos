class CreateDiningTables < ActiveRecord::Migration[7.1]
  def change
    create_table :dining_tables do |t|
      t.references :tenant, null: false, foreign_key: true
      t.string :code
      t.integer :capacity
      t.string :status, default: "free", null: false

      t.timestamps

    end
  end
end
