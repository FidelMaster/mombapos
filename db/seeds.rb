# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
#   
#

#clear tables
puts "Inserting License...."
puts "License count: #{License.count}"
if License.count == 0
    License.create!(
        name: "Demo License",
        price: 0,
    )

    License.create!(
        name: "Basica",
        price: 20,
    )

    License.create!(
        name: "Premium",
        price: 50,
    )
end

puts "App Modules....."
puts "App Module count: #{AppModule.count}"
if AppModule.count == 0
  AppModule.create!(
    name: "Inventario",
    code: "inventory",
  )

  AppModule.create!(
    name: "Facturacion",
    code: "billing",
  )

  AppModule.create!(
    name: "Restaurante",
    code: "restaurant",

  )

  AppModule.create!(
    name: "Academico",
    code: "academic",
  
  )
end
puts "Inserting  Tenants..."
puts "Tenant count: #{Tenant.count}"

if Tenant.count == 0
  tenant = Tenant.create!(
    name: "Demo Company",
    subdomain: "demo",
    uuid: SecureRandom.uuid,
    max_users: 5,
    max_invoices: 1000,
    max_branches: 1,
    max_products: 100,
    default_currency: "NIO",
    timezone: "America/Managua",
    is_active: true,
    email: "developerfhernandez@gmail.com",
    license_id: 1
  )

  Branch.create!(
    tenant: tenant,
    name: "Sucursal 1",
    is_default: true,
    is_active: true
  )

  User.create!(
    tenant: tenant,
    email: "admin@demo.com",
    password: "password123",
    role: :owner
  )
else 
  tenant = Tenant.first
end

Current.tenant = tenant

puts "Inserting levels..."
puts "Level count: #{Level.count}"
if Level.count == 0
  Level.create!(
    tenant: tenant,
    name: "Principiante"
  )

  Level.create!(
    tenant: tenant,
    name: "Intermedio"
  )

  Level.create!(
    tenant: tenant,
    name: "Avanzado"
  )
end

puts "Inserting countries..."
puts "Country count: #{Country.count}"
puts "Department count: #{Department.count}"
puts "Municipality count: #{Municipality.count}"


if Country.count == 0
  country =Country.create!(
    name: "Nicaragua",
    code: "505"
  )
else 
  country = Country.first
end

if Department.count == 0
  department =Department.create!(
    name: "Managua",
    country_id: country.id,
    is_active: true
  )

  Department.create!(
    name: "Masaya",
    country_id: country.id,
    is_active: true
  )

  Department.create!(
    name: "Chinandega",
    country_id: country.id,
    is_active: true
  )
end

if Municipality.count == 0
  Municipality.create!(
    name: "Managua",
    department_id: department.id,
    is_active: true
  )
end

puts "Inserting dining tables..."
puts "Dining table count: #{DiningTable.count}"
if DiningTable.count == 0
  DiningTable.create!(
    tenant: tenant,
    code: "Mesa 1",
    capacity: 4,
    status: :free
  )

  DiningTable.create!(
    tenant: tenant,
    code: "Mesa 2",
    capacity: 4,
    status: :free
  )

  DiningTable.create!(
    tenant: tenant,
    code: "Mesa 3",
    capacity: 4,
    status: :free
  )
end

puts "insering Payment terms....."
if  PaymentTerm.count == 0
  PaymentTerm.create!(
    name: "Contado",
    description: "Pago de contado",
    total: 0
  )

  PaymentTerm.create!(
    name: "Credito 15 dias",
    description: "Pago en 15 dias",
    total: 15
  )

  PaymentTerm.create!(
    name: "Credito 30 dias",
    description: "Pago en 30 dias",
    total: 30
  )

  PaymentTerm.create!(
    name: "Credito 60 dias",
    description: "Pago en 60 dias",
    total: 60
  )
end

 

puts "Inserting exchange rates..."
if ExchangeRate.count == 0
  ExchangeRate.create!(
    tenant: tenant,
    currency: "USD",
    rate: 36.80, # Example rate
    effective_date: Date.today
  )
end
