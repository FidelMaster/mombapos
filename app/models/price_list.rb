class PriceList < ApplicationRecord
  belongs_to :tenant

  has_many :price_list_items

  default_scope { where(tenant_id: Current.tenant.id) }

  validates :tenant, presence: true
end
