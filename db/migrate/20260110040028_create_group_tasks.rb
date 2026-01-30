class CreateGroupTasks < ActiveRecord::Migration[7.1]
  def change
    create_table :group_tasks do |t|
      t.references :group, null: false, foreign_key: true
      t.string :name
      t.text :description
      t.text :observation
      t.date :start_date
      t.date :end_date

      t.timestamps
    end
  end
end
