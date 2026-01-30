class CreateTaxes < ActiveRecord::Migration[7.1]
  def change
    create_table :taxes do |t|
      t.references :tenant, null: false, foreign_key: true
      t.string :name
      t.decimal :rate_percentage
      t.boolean :is_active

      t.timestamps
    end
  end
end
