class Plan < ApplicationRecord
  belongs_to :tenant
  belongs_to :trainer
  belongs_to :student
  has_many :plan_details, dependent: :destroy
  has_many :plan_extra_controls, dependent: :destroy


  default_scope { where(tenant_id: Current.tenant.id) }

end
