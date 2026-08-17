class Role < ApplicationRecord
  belongs_to :tenant
  has_many :permissions, dependent: :destroy
  has_many :users, dependent: :nullify

  accepts_nested_attributes_for :permissions, allow_destroy: true

  validates :name, presence: true, uniqueness: { scope: :tenant_id }
end
