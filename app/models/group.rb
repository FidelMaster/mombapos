class Group < ApplicationRecord
  belongs_to :tenant
  belongs_to :trainer
  has_many :group_members, dependent: :destroy
  has_many :group_tasks, dependent: :destroy

  default_scope { where(tenant_id: Current.tenant.id) }

  enum status: { abierto: "open", en_proceso: "in_progress", finalizado: "closed" }
end
