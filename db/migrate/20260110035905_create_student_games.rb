class CreateStudentGames < ActiveRecord::Migration[7.1]
  def change
    create_table :student_games do |t|
      t.references :tenant, null: false, foreign_key: true
      t.references :student, null: false, foreign_key: true
      t.string :opponent_fide_code
      t.string :opponent_name
      t.integer :opponent_elo
      t.decimal :student_average_score
      t.string :result

      t.timestamps
    end
  end
end
