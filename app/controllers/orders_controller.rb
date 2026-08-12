class OrdersController < ApplicationController
  before_action :set_order, only: %i[ show edit update destroy ]

  # GET /orders/history
  def history
    @active_orders = Order.where(status: :open).order(created_at: :desc)
    @pickup_orders = @active_orders.where(order_type: :pickup)
    @closed_orders = Order.where(status: [:closed, :cancelled]).order(created_at: :desc).limit(50)
  end

  # GET /orders/1
  def show
    respond_to do |format|
      format.html
      format.json { render json: @order.as_json(include: { order_items: { include: :product } }) }
    end
  end

  # GET /orders/new
  def new
    @order = Order.new
    @order.order_type = params[:order_type] if params[:order_type].present?
    
    if @order.pickup? || @order.delivery?
       render :new_pickup
    end
  end

  # GET /orders/1/edit
  def edit
  end

  # POST /orders
  def create
    @order = Order.new(order_params)
    @order.tenant_id = Current.tenant.id

    respond_to do |format|
      if @order.save
        # Update table status
        @order.dining_table.update(status: :occupied) if @order.dining_table
        
        path = if @order.dining_table
                 pos_table_path(@order.dining_table)
               else
                 pos_order_path(@order) 
               end

        format.html { redirect_to path, notice: "Order was successfully created." }
        format.json { render json: @order.as_json(include: { order_items: { include: :product } }), status: :created }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /orders/1
  def update
    respond_to do |format|
      if @order.update(order_params)
        format.html { redirect_to @order, notice: "Order was successfully updated.", status: :see_other }
        format.json { render json: @order.as_json(include: { order_items: { include: :product } }), status: :ok }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /orders/1
  def destroy
    @order.destroy!
    redirect_to orders_url, notice: "Order was successfully destroyed.", status: :see_other
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_order
      @order = Order.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def order_params
      params.require(:order).permit(:tenant_id, :order_code, :dining_table_id, :customer_id, :customer_name, :status, :total_items, :total, :order_type,
                                   order_items_attributes: [:id, :product_id, :quantity, :unit_price, :subtotal, :notes, :_destroy])
    end
end
