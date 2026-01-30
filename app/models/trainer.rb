class Trainer < ApplicationRecord
  belongs_to :tenant
  belongs_to :user
  belongs_to :department
  belongs_to :municipality

  default_scope { where(tenant_id: Current.tenant.id) }

  validates :tenant, presence: true
end
