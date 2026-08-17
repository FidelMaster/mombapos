class User < ApplicationRecord
  devise :database_authenticatable,
         :recoverable,
         :rememberable,
         :validatable

  belongs_to :tenant
  belongs_to :app_role, class_name: "Role", foreign_key: "role_id", optional: true

  scope :active, -> { where(is_active: true) }

  def active_for_authentication?
    super && is_active?
  end

  def owner?
    app_role&.name == "owner"
  end

  def admin?
    app_role&.name == "admin"
  end

  def accountant?
    app_role&.name == "accountant"
  end

  def seller?
    app_role&.name == "seller"
  end

end
