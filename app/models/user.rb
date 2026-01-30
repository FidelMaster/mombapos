class User < ApplicationRecord
  devise :database_authenticatable,
         :recoverable,
         :rememberable,
         :validatable

  belongs_to :tenant

  enum role: {
    owner: 0,
    admin: 1,
    accountant: 2,
    seller: 3
  }

  scope :active, -> { where(is_active: true) }

  def active_for_authentication?
    super && is_active?
  end
end
