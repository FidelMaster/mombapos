class PlanExtraControl < ApplicationRecord
  belongs_to :plan
  has_many :plan_extra_control_details, dependent: :destroy

end
