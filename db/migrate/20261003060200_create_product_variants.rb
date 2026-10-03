class CreateProductVariants < ActiveRecord::Migration[7.1]
  def change
    create_table :product_variants do |t|
      t.references :tenant,  null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true

      t.string  :sku, null: false
      t.string  :variant_name                     # Ej: "Oro 14K Amarillo - Talla 7"
      t.string  :metal_type                       # Oro, Plata, Platino...
      t.string  :karat                            # 10k, 14k, 18k, 925
      t.string  :size                             # Talla / medida
      t.decimal :weight_grams, precision: 8,  scale: 3, default: 0.0, null: false
      t.decimal :cost,         precision: 12, scale: 2, default: 0.0, null: false
      t.decimal :price,        precision: 12, scale: 2, default: 0.0, null: false
      t.boolean :is_active, default: true, null: false

      t.timestamps
    end

    # El SKU es único dentro de cada tenant (multi-tenant).
    add_index :product_variants, %i[tenant_id sku], unique: true
    add_index :product_variants, %i[product_id is_active]
  end
end
