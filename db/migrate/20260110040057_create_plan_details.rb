class CreatePlanDetails < ActiveRecord::Migration[7.1]
  def change
    create_table :plan_details do |t|
      t.references :plan, null: false, foreign_key: true
      t.string :name
      t.integer :duration_in_days

      t.timestamps
    end
  end
end
