class CreateMenuItems < ActiveRecord::Migration[7.0]
  def change
    create_table :menu_items do |t|
      t.string  :key, null: false
      t.string  :label, null: false
      t.string  :icon
      t.string  :path
      t.string  :section
      t.integer :position

      t.string  :item_type, null: false
      t.references :parent, null: true, foreign_key: { to_table: :menu_items }

      t.timestamps
    end

    add_index :menu_items, :key, unique: true
    add_index :menu_items, :item_type
  end
end
