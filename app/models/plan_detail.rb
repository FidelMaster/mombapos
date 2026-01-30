class PlanDetail < ApplicationRecord
  belongs_to :plan
  has_many :plan_detail_structures, dependent: :destroy
  has_many :plan_detail_objectives, dependent: :destroy

end
