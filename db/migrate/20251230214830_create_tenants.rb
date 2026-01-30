class CreateTenants < ActiveRecord::Migration[7.1]
  def change
    create_table :tenants do |t|
      t.string :uuid
      t.string :name
      t.string :subdomain
      t.string :logo_url
      t.integer :max_users
      t.integer :max_invoices
      t.integer :max_branches
      t.integer :max_products
      t.string :default_currency
      t.string :timezone
      t.boolean :is_active

      t.timestamps
    end
  end
end
