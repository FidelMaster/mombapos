class StockMovementsController < ApplicationController
  def index
    @movements = StockMovement.order(created_at: :desc).limit(50)
  end

  def new
    @stock_movement = StockMovement.new
    @products = Product.all
    @warehouses = Warehouse.all
  end

  def create
    @stock_movement = StockMovement.new(stock_movement_params)
    @stock_movement.tenant = Current.tenant
    @stock_movement.branch = Current.tenant.branches.first # Default branch or select
    
    # Handle reference (optional, set to user or manual adjustment)
    # @stock_movement.reference = current_user 

    if @stock_movement.save
      redirect_to stock_movements_path, notice: "Movimiento de inventario registrado correctamente."
    else
      @products = Product.all
      @warehouses = Warehouse.all
      render :new, status: :unprocessable_entity
    end
  end

  private

  def stock_movement_params
    params.require(:stock_movement).permit(:warehouse_id, :product_id, :quantity, :movement_type)
  end
end
