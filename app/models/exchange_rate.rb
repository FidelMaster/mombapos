class ExchangeRate < ApplicationRecord
  belongs_to :tenant

  default_scope { where(tenant_id: Current.tenant.id) }
end
