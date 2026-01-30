class FixUnitMeasureForeignKeysOnProducts < ActiveRecord::Migration[7.1]
  def change
    # Eliminar FK incorrectas
    remove_foreign_key :products, :stock_unit_measures rescue nil
    remove_foreign_key :products, column: :sale_unit_measure_id rescue nil

    # Agregar FK correctas
    add_foreign_key :products, :unit_measures, column: :stock_unit_measure_id
    add_foreign_key :products, :unit_measures, column: :sale_unit_measure_id
  end
end
