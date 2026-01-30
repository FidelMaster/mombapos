class CreateTrainers < ActiveRecord::Migration[7.1]
  def change
    create_table :trainers do |t|
      t.references :tenant, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :name
      t.string :email
      t.string :phone
      t.decimal :rate_per_hour
      t.date :hire_date
      t.references :department, null: false, foreign_key: true
      t.references :municipality, null: false, foreign_key: true

      t.timestamps
    end
  end
end
