class Branch < ApplicationRecord
  belongs_to :tenant

  has_many :invoice

  default_scope { where(tenant_id: Current.tenant.id) }

  validates :tenant, presence: true
end
