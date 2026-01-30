class GroupMember < ApplicationRecord
  belongs_to :group
  belongs_to :student
  enum status: { Activo: "active", Inactivo: "inactive"}
end
