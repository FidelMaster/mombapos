class AddCustomOrderFieldsToOrders < ActiveRecord::Migration[7.1]
  def up
    add_column :orders, :order_kind, :string, default: "standard", null: false  # standard | custom_order
    add_column :orders, :advance_amount, :decimal, precision: 12, scale: 2, default: 0.0, null: false
    add_column :orders, :balance_amount, :decimal, precision: 12, scale: 2, default: 0.0, null: false
    add_column :orders, :promised_delivery_date, :date
    add_column :orders, :workshop_notes, :text

    # NOTA: `status` sigue siendo string. El POS de restaurante continúa usando
    # "open"/"closed"; el flujo de pedidos de joyería usa draft → completed.
    # Por eso se conserva el default "open" a nivel BD (el modelo define el valor
    # inicial correcto según el flujo).

    add_index :orders, %i[tenant_id status]
    add_index :orders, %i[tenant_id order_kind]
    add_index :orders, %i[tenant_id promised_delivery_date]

    # Backfill: las órdenes existentes no tienen anticipos → saldo = total.
    execute "UPDATE orders SET balance_amount = COALESCE(total, 0)"
  end

  def down
    remove_index :orders, %i[tenant_id promised_delivery_date]
    remove_index :orders, %i[tenant_id order_kind]
    remove_index :orders, %i[tenant_id status]

    remove_column :orders, :workshop_notes
    remove_column :orders, :promised_delivery_date
    remove_column :orders, :balance_amount
    remove_column :orders, :advance_amount
    remove_column :orders, :order_kind
  end
end
