class Bank < ApplicationRecord
  belongs_to :tenant

  has_many :bank_account

  default_scope { where(tenant_id: Current.tenant.id) }

  validates :tenant, presence: true

end
