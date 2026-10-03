# app/models/user.rb
class User < ApplicationRecord
  devise :database_authenticatable,
         :recoverable,
         :timeoutable, # Cierra la sesión tras inactividad
         :validatable

  belongs_to :tenant
  belongs_to :app_role, class_name: "Role", foreign_key: "role_id", optional: true

  enum role: { owner: 0, admin: 1, manager: 2, staff: 3, cashier: 4, waiter: 5, waitress: 6 }
  
  scope :active, -> { where(is_active: true) }

  # Configuración de timeout por modelo (opcional, también se puede en config/initializers/devise.rb)
  def timeout_in
    15.minutes
  end

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

  # Solo los vendedores pueden operar la caja registradora
  def can_operate_cash_register?
    seller?
  end
end