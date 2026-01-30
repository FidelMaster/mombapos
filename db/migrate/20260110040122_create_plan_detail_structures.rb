class CreatePlanDetailStructures < ActiveRecord::Migration[7.1]
  def change
    create_table :plan_detail_structures do |t|
      t.references :plan_detail, null: false, foreign_key: true
      t.string :title

      t.timestamps
    end
  end
end
