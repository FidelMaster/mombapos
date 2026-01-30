class Student < ApplicationRecord
  belongs_to :tenant
  belongs_to :level
  belongs_to :department
  belongs_to :municipality
  belongs_to :country

  default_scope { where(tenant_id: Current.tenant.id) }

  validates :tenant, presence: true
end
