class Area < ApplicationRecord
  belongs_to :tenant
  has_many :dining_tables

  validates :name, presence: true, length: { minimum: 2 }
  
  default_scope { where(tenant_id: Current.tenant.id) }
end
