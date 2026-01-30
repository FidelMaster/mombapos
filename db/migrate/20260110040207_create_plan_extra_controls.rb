class CreatePlanExtraControls < ActiveRecord::Migration[7.1]
  def change
    create_table :plan_extra_controls do |t|
      t.references :plan, null: false, foreign_key: true
      t.string :control_type

      t.timestamps
    end
  end
end
