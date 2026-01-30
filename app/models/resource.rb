class Resource < ApplicationRecord
  belongs_to :tenant
  belongs_to :level

  default_scope { where(tenant_id: Current.tenant.id) }

  validates :tenant, presence: true
end
