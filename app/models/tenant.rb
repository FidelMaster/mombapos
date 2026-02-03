class Tenant < ApplicationRecord
  belongs_to :license, optional: true
  has_many :users
  has_many :invoices
  has_many :products
  has_many :banks
  has_many :branches
  has_many :customers
  has_many :suppliers
  has_many :warehouses
  has_many :unit_measures
  has_many :bank_accounts
  has_many :areas
  has_many :exchange_rates
  has_many :tenant_modules, dependent: :destroy
  has_many :app_modules, through: :tenant_modules

  enum default_currency: { NIO: "NIO", USD: "USD" }

  after_create :initialize_tenant

  validates_presence_of :email, :name, :subdomain, :license_id

  private

  def initialize_tenant
    # 1. Copy modules from license if present
    if license.present?
      license.app_modules.each do |app_module|
        tenant_modules.create(app_module: app_module, enabled: true)
      end
    end

    # 2. Create default Branch
    branches.unscoped.create!(
      tenant: self,
      name: "Casa Matriz - #{name}",
      is_default: true,
      is_active: true
    )

    # 3. Create default Warehouse
    warehouses.unscoped.create(
      tenant: self,
      name: "Bodega General - #{name}",
      is_default: true,
      is_active: true
    )

    # 4. Create default Price List
    PriceList.unscoped.create( 
      tenant: self,
      name: "Lista de Precios Base",
      currency: default_currency,
      is_active: true
    )

    #5. Create default User
    users.unscoped.create(
      tenant: self,
      email: email,
      password: "password123",
      role: :admin,
      is_active: true
    )

    #6. Create default Customer Generic
    customers.unscoped.create(
      tenant: self,
      name: "Cliente Generico",
      address: "Casa Matriz - #{name}",
      municipality_id: 1,
      department_id: 1,
      contact_name: "Cliente Generico",
      contact_email: "cliente_generico@#{name}.com",
      contact_phone: "12345678",
      credit_limit: 0,
      is_tax_exempt: false,
      is_active: true
    )
  end
end
