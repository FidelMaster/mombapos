class PlanDetailStructure < ApplicationRecord
  belongs_to :plan_detail
  has_many :plan_detail_structure_tasks, dependent: :destroy

end
