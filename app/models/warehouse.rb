class Warehouse < ApplicationRecord
  belongs_to :tenant

  default_scope { where(tenant_id: Current.tenant.id) }

  validates :tenant, presence: true
end
