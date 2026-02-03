class AppModule < ApplicationRecord
  has_many :tenant_modules, dependent: :destroy
  has_many :tenants, through: :tenant_modules

  has_many :app_modules_menu_items, dependent: :destroy
  has_many :menu_items, through: :app_modules_menu_items
end
