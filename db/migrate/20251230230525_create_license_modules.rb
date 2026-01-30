class CreateLicenseModules < ActiveRecord::Migration[7.1]
  def change
    create_table :license_modules do |t|
      t.references :license, null: false, foreign_key: true
      t.references :app_module, null: false, foreign_key: true

      t.timestamps
    end
  end
end
