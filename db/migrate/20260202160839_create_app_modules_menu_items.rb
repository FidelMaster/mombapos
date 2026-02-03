class CreateAppModulesMenuItems < ActiveRecord::Migration[7.0]
  def change
    create_table :app_modules_menu_items do |t|
      t.references :app_module, null: false, foreign_key: true
      t.references :menu_item, null: false, foreign_key: true

      t.timestamps
    end

    add_index :app_modules_menu_items,
              [:app_module_id, :menu_item_id],
              unique: true,
              name: 'index_modules_menu_unique'
  end
end
