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
    @stock_movement.branch ||= Current.tenant.branches.first

    # Usamos una transacción para garantizar atomicidad (todo se guarda o nada se guarda)
    ActiveRecord::Base.transaction do
      # 1. Guardar primero el movimiento (si no es válido, se va al rescue/else)
      @stock_movement.save!

      # 2. Buscar o inicializar el stock en el almacén seleccionado en el formulario
      stock_warehouse = WarehouseStock.find_or_initialize_by(
        product_id: @stock_movement.product_id,
        warehouse_id: @stock_movement.warehouse_id
      )
      
      stock_warehouse.stock_available ||= 0
      product = @stock_movement.product

      # 3. Calcular la variación de stock
      factor = @stock_movement.movement_type == "in" ? 1 : -1
      delta = @stock_movement.quantity * factor

      # 4. Actualizar las cantidades de forma segura
      stock_warehouse.update!(stock_available: stock_warehouse.stock_available + delta)
      product.update!(quantity: product.quantity + delta)
    end

    redirect_to stock_movements_path, notice: "Movimiento de inventario registrado correctamente."

  rescue ActiveRecord::RecordInvalid => e
    # Si falla la validación del movimiento o alguna actualización, vuelve a renderizar
    render :new, status: :unprocessable_entity
  end

  private

  def stock_movement_params
    params.require(:stock_movement).permit(:warehouse_id, :product_id, :quantity, :movement_type)
  end
end
