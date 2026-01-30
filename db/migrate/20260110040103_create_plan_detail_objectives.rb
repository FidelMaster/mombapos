class CreatePlanDetailObjectives < ActiveRecord::Migration[7.1]
  def change
    create_table :plan_detail_objectives do |t|
      t.references :plan_detail, null: false, foreign_key: true
      t.text :description
      t.boolean :is_active

      t.timestamps
    end
  end
end
