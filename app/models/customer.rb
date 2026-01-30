class Customer < ApplicationRecord
  belongs_to :tenant
  belongs_to :department
  belongs_to :municipality

  has_many :customer_addresses, dependent: :destroy
  has_many :invoices, dependent: :destroy
  has_many :document_account_receivables

  default_scope { where(tenant_id: Current.tenant.id) }

  validates :tenant, presence: true

end
