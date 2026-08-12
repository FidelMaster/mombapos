class StockWarehousesController < ApplicationController
  def index
    @warehouses = Warehouse.all
    
    if params[:warehouse_id].present?
      @warehouse = Warehouse.find_by(id: params[:warehouse_id])
    else
      @warehouse = Warehouse.find_by(is_default: true) || @warehouses.first
    end

    if @warehouse
      @stocks = WarehouseStock
            .joins(:product)
            .where(warehouse: @warehouse)
            .merge(Product.stockables)
            .includes(:product)
            .order('products.name ASC')
    else
      @stocks = []
    end
  end

  def show
  end

  def new
  end

  def edit
  end
end
