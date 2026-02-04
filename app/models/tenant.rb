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
    Current.set(tenant: self) do
    # 1. Copy modules
    if license.present?
      license.app_modules.each do |app_module|
        tenant_modules.create!(app_module: app_module, enabled: true)
      end
    end

    branches.create!(
      name: "Casa Matriz - #{name}",
      is_default: true,
      is_active: true
    )

    warehouses.create!(
      name: "Bodega General - #{name}",
      is_default: true,
      is_active: true
    )

    PriceList.create!(
      tenant: self,
      name: "Lista de Precios Base",
      currency: default_currency,
      is_active: true
    )

    users.create!(
      email: email,
      password: "password123",
      role: :admin,
      is_active: true
    )

    customers.create!(
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

    suppliers.create!(
      name: "ND - No Definido",
      contact_name: "ND - No Definido",
      contact_email: "nd@#{name}.com",
      contact_phone: "12345678",
      is_active: true
    )

    unit_measures.create!(
      name: "Unidad",
      abbreviation: "UND"
    )
    end
  end
end
