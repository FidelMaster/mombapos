class UnitMeasure < ApplicationRecord
  belongs_to :tenant

  has_many :product

  default_scope { where(tenant_id: Current.tenant.id) }
end
