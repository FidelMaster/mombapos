class CreateTenantModules < ActiveRecord::Migration[7.1]
  def change
    create_table :tenant_modules do |t|
      t.references :tenant, null: false, foreign_key: true
      t.references :app_module, null: false, foreign_key: true
      t.boolean :enabled

      t.timestamps
    end
  end
end
