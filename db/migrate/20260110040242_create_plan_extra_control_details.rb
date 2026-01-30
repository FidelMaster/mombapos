class CreatePlanExtraControlDetails < ActiveRecord::Migration[7.1]
  def change
    create_table :plan_extra_control_details do |t|
      t.references :plan_extra_control, null: false, foreign_key: true
      t.text :observation

      t.timestamps
    end
  end
end
