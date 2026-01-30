class CreateGroupMembers < ActiveRecord::Migration[7.1]
  def change
    create_table :group_members do |t|
      t.references :group, null: false, foreign_key: true
      t.references :student, null: false, foreign_key: true
      t.decimal :score
      t.string :status

      t.timestamps
    end
  end
end
