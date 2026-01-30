class AddDeliveryFieldsToOrders < ActiveRecord::Migration[7.1]
  def change
    change_column_null :orders, :dining_table_id, true
    add_column :orders, :order_type, :integer, default: 0 # 0: dine_in, 1: delivery, 2: pickup
    add_column :orders, :delivery_address, :text
    add_column :orders, :customer_phone, :string
    add_column :orders, :latitude, :decimal, precision: 10, scale: 6
    add_column :orders, :longitude, :decimal, precision: 10, scale: 6

    add_column :customer_addresses, :name, :string, default: "Direccion 1"
  end
end
