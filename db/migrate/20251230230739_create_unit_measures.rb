class CreateUnitMeasures < ActiveRecord::Migration[7.1]
  def change
    create_table :unit_measures do |t|
      t.references :tenant, null: false, foreign_key: true
      t.string :name
      t.string :abbreviation

      t.timestamps
    end
  end
end
