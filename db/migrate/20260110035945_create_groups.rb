class CreateGroups < ActiveRecord::Migration[7.1]
  def change
    create_table :groups do |t|
      t.references :tenant, null: false, foreign_key: true
      t.references :trainer, null: false, foreign_key: true
      t.string :name
      t.text :description
      t.date :execution_date
      t.date :end_date
      t.time :execution_hour
      t.string :status
      t.integer :max_students
      t.integer :duration_in_minutes
      t.decimal :price
      t.decimal :total_incomes

      t.timestamps
    end
  end
end
