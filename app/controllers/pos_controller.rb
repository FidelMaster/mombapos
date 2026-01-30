class PosController < ApplicationController
  def index
    @areas = Area.includes(:dining_tables).order(:name)
    @dining_tables = DiningTable.includes(:area, :orders).order(:code)
  end

  def show
    @dining_table = DiningTable.find(params[:id])
    @order = @dining_table.orders.find_by(status: :open)
    load_pos_data
  end

  def show_order
    @order = Order.find(params[:id])
    @dining_table = @order.dining_table # May be nil for pickup
    load_pos_data
    render :show
  end

  def pickup
    @order = Order.new(order_type: :pickup)
    @dining_table = nil
    load_pos_data
    render :show
  end

  private

  def load_pos_data
    # If no open order, we'll initialize a new one in the view or via a button
    @categories = ProductCategory.where(is_active: true)
    @products = Product.where(is_active: true).includes(:product_category)
    
    # We need a default customer for POS if one isn't provided
    @customers = Customer.where(is_active: true).limit(10)
    @default_customer = Customer.find_or_create_by!(name: "Consumidor Final", tenant_id: Current.tenant.id, department_id: Department.first&.id, municipality_id: Municipality.first&.id, is_active: true)
  end
end
