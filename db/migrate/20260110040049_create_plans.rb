class CreatePlans < ActiveRecord::Migration[7.1]
  def change
    create_table :plans do |t|
      t.references :tenant, null: false, foreign_key: true
      t.references :trainer, null: false, foreign_key: true
      t.references :student, null: false, foreign_key: true
      t.string :name
      t.text :description
      t.text :observation
      t.boolean :is_active
      t.integer :total_duration_in_days
      t.string :tournament
      t.string :event
      t.date :event_date
      t.text :event_observation

      t.timestamps
    end
  end
end
