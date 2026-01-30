class CreateAppModules < ActiveRecord::Migration[7.1]
  def change
    create_table :app_modules do |t|
      t.string :code
      t.string :name

      t.timestamps
    end
  end
end
