class TenantModule < ApplicationRecord
  belongs_to :tenant
  belongs_to :app_module
end
