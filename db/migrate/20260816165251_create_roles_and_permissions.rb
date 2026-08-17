class CreateRolesAndPermissions < ActiveRecord::Migration[7.1]
  class MigrationTenant < ActiveRecord::Base
    self.table_name = :tenants
  end

  class MigrationRole < ActiveRecord::Base
    self.table_name = :roles
  end

  class MigrationPermission < ActiveRecord::Base
    self.table_name = :permissions
  end

  class MigrationUser < ActiveRecord::Base
    self.table_name = :users
  end

  def change
    create_table :roles do |t|
      t.string :name, null: false
      t.references :tenant, null: false, foreign_key: true

      t.timestamps
    end

    create_table :permissions do |t|
      t.references :role, null: false, foreign_key: { to_table: :roles, on_delete: :cascade }
      t.string :action, null: false
      t.string :subject_class, null: false

      t.timestamps
    end

    add_reference :users, :role, foreign_key: true

    reversible do |dir|
      dir.up do
        # For each tenant, create the 4 default roles and permissions
        MigrationTenant.find_each do |tenant|
          # Create owner role
          owner_role = MigrationRole.create!(name: "owner", tenant_id: tenant.id)
          MigrationPermission.create!(role_id: owner_role.id, action: "manage", subject_class: "all")

          # Create admin role
          admin_role = MigrationRole.create!(name: "admin", tenant_id: tenant.id)
          MigrationPermission.create!(role_id: admin_role.id, action: "manage", subject_class: "all")

          # Create accountant role
          accountant_role = MigrationRole.create!(name: "accountant", tenant_id: tenant.id)
          [
            ["read", "Invoice"], ["read", "BankAccount"], ["read", "Bank"], 
            ["read", "DocumentAccountReceivable"], ["read", "Receipt"], ["read", "ExchangeRate"],
            ["manage", "BankAccount"], ["manage", "DocumentAccountReceivable"], ["manage", "Receipt"],
            ["read", "Product"], ["read", "Customer"], ["read", "Branch"], ["read", "Warehouse"],
            ["read", "dashboard"], ["read", "reports"]
          ].each do |action, subject|
            MigrationPermission.create!(role_id: accountant_role.id, action: action, subject_class: subject)
          end

          # Create seller role
          seller_role = MigrationRole.create!(name: "seller", tenant_id: tenant.id)
          [
            ["manage", "Order"], ["manage", "Customer"],
            ["read", "Invoice"], ["create", "Invoice"], ["new", "Invoice"],
            ["read", "Product"], ["read", "ProductCategory"], ["read", "DiningTable"],
            ["read", "Area"], ["read", "Branch"], ["read", "Warehouse"],
            ["access", "pos"]
          ].each do |action, subject|
            MigrationPermission.create!(role_id: seller_role.id, action: action, subject_class: subject)
          end

          # Map users of this tenant to their new role_id based on enum role integer
          MigrationUser.where(tenant_id: tenant.id).find_each do |user|
            role_to_assign = case user.role
                             when 0 then owner_role
                             when 1 then admin_role
                             when 2 then accountant_role
                             when 3 then seller_role
                             else admin_role
                             end
            user.update_columns(role_id: role_to_assign.id)
          end
        end
      end
    end
  end
end

