class CreateCurrency < ActiveRecord::Migration[7.1]
  def change
    create_table :currencies do |t|
      t.string :code, null: false        # NIO, USD, EUR
      t.string :name, null: false        # Córdoba, Dollar, Euro
      t.string :symbol, null: false      # C$, U$, €
      t.string :locale                  # es-NI, en-US
      t.boolean :is_active, default: true
      t.timestamps
    end

    add_index :currencies, :code, unique: true
  end
end
