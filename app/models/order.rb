class Order < ApplicationRecord
  belongs_to :tenant
  belongs_to :dining_table, optional: true
  belongs_to :customer

  enum status: {
    open: "open",
    closed: "closed",
    cancelled: "cancelled"
  }

  enum order_type: {
    dine_in: 0,
    delivery: 1,
    pickup: 2
  }
  
  has_many :order_items, dependent: :destroy
  has_one :invoice, dependent: :nullify
  accepts_nested_attributes_for :order_items, allow_destroy: true

  before_validation :set_defaults, on: :create
  before_save :calculate_totals

  default_scope { where(tenant_id: Current.tenant.id) }


  private

  def set_defaults
    self.tenant_id ||= Current.tenant&.id
    self.status ||= :open
    self.order_code ||= "ORD-#{SecureRandom.hex(4).upcase}"
    self.customer_name ||= customer&.name if customer
  end

  def calculate_totals
    self.total_items = order_items.sum(&:quantity)
    self.total = order_items.sum(&:subtotal)
  end
end
