class AddJewelryFieldsToOrderItems < ActiveRecord::Migration[7.1]
  def change
    add_reference :order_items, :product_variant, null: true, foreign_key: true
    add_column :order_items, :engraving_text, :string          # Texto de grabado personalizado
    add_column :order_items, :custom_specifications, :text     # Instrucciones de confección / engaste
  end
end
