class CreateStudents < ActiveRecord::Migration[7.1]
  def change
    create_table :students do |t|
      t.references :tenant, null: false, foreign_key: true
      t.references :level, null: false, foreign_key: true
      t.references :department, null: false, foreign_key: true
      t.references :municipality, null: false, foreign_key: true
      t.string :name
      t.string :address
      t.string :contact_dni
      t.string :contact_name
      t.string :contact_email
      t.string :contact_phone
      t.date :date_of_birth
      t.string :code
      t.decimal :official_average_score
      t.decimal :online_average_score
      t.string :title

      t.timestamps
    end
  end
end
