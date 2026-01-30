class BankAccount < ApplicationRecord
  belongs_to :bank
  belongs_to :tenant

  default_scope { where(tenant_id: Current.tenant.id) }

  def full_name
    "#{account_number} - #{bank.name} - #{account_name} #{currency}"
  end
end
