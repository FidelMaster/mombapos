class DiningTable < ApplicationRecord
  belongs_to :tenant
  belongs_to :area, optional: true

  enum status: {
    free: "free",
    reserved: "reserved",
    occupied: "occupied"
  }

  has_many :orders

  default_scope { where(tenant_id: Current.tenant.id) }

end
