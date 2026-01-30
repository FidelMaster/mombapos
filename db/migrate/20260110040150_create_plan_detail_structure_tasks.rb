class CreatePlanDetailStructureTasks < ActiveRecord::Migration[7.1]
  def change
    create_table :plan_detail_structure_tasks do |t|
      t.references :plan_detail_structure, null: false, foreign_key: true
      t.string :turn
      t.text :description
      t.integer :percentage
      t.boolean :is_complete

      t.timestamps
    end
  end
end
