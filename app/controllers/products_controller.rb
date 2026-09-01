class ProductsController < ApplicationController
  before_action :set_product, only: %i[ show edit update destroy ]

  # GET /products
  def index
    # Base query with optional filters
    @products = Product.all
    @products = apply_filters(@products)
    @products = apply_search(@products)
    @products = apply_sorting(@products)

    # Handle export request
    if params[:format] == "csv"
      return export_to_excel(@products)
    end

    # Store filtered count for dashboard indicators
    filtered_products = @products
     
    # Dashboard indicators (from filtered but unpaginated collection)
    @total_products = filtered_products.count
    @total_stock = filtered_products.sum("COALESCE(quantity, 0)")
    @inventory_sale_value = filtered_products.sum("COALESCE(quantity, 0) * COALESCE(price, 0)")
    @inventory_cost_value = filtered_products.sum("COALESCE(quantity, 0) * COALESCE(cost, 0)")
  end

  # GET /products/1
  def show
  end

  # GET /products/new
  def new
    @product = Product.new
    
    default_warehouse = Warehouse.find_by(is_default: true)
    @product.warehouse_stocks.build(warehouse: default_warehouse) if default_warehouse

    # Assuming the first active price list is the default one as there is no is_default flag yet
    default_price_list = PriceList.where(is_active: true).first
    @product.price_list_items.build(price_list: default_price_list) if default_price_list

    load_form_collections
  end

  # GET /products/1/edit
  def edit
    load_form_collections
  end

  # POST /products
  def create
    @product = Product.new(product_params)
    @product.tenant = Current.tenant

    if @product.save
      redirect_to @product, notice: "Product was successfully created."
    else
      load_form_collections
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /products/1
  def update
    #check if user is admin or owner
    if !current_user.admin? && !current_user.owner?
      redirect_to @product, alert: "Usted no tiene permiso para editar este producto."
    end
    
    if @product.update(product_params)
      redirect_to @product, notice: "Producto actualizado exitosamente.", status: :see_other
    else
      load_form_collections
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /products/1
  def destroy
    @product.destroy!
    redirect_to products_url, notice: "Product was successfully destroyed.", status: :see_other
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_product
      @product = Product.find(params[:id])
    end

    def load_form_collections
      @categories = ProductCategory.order(:name)
      @unit_measures = UnitMeasure.order(:name)
      @suppliers = Supplier.order(:name)
      @bank_accounts = BankAccount.order(:account_name)
    end

    # Only allow a list of trusted parameters through.
    def product_params
      params.require(:product).permit(
        :product_code, 
        :name, 
        :description, 
        :product_type, 
        :product_category_id, 
        :cost, 
        :quantity,
        :stock_unit_measure_id, 
        :sale_unit_measure_id, 
        :is_active,
        :price,
        :supplier_id,
        warehouse_stocks_attributes: [:id, :warehouse_id, :stock_available, :_destroy],
        price_list_items_attributes: [:id, :price_list_id, :price]
      )
    end

    # Apply dynamic filters (category, status, warehouse, etc.)
    def apply_filters(collection)
      collection = collection.where(product_category_id: params[:category_id]) if params[:category_id].present?
      collection = collection.where(product_type: params[:product_type]) if params[:product_type].present?
      collection = collection.where(supplier_id: params[:supplier_id]) if params[:supplier_id].present?
      collection = collection.where(is_active: params[:is_active]) if params[:is_active].present?
      collection
    end

    # Apply smart search on multiple fields
    def apply_search(collection)
      return collection unless params[:q].present?
      
      search_term = "%#{params[:q]}%"
      collection.where(
        "product_code ILIKE ? OR name ILIKE ? OR description ILIKE ?",
        search_term, search_term, search_term
      )
    end

    # Apply sorting with persistence
    def apply_sorting(collection)
      if params[:sort].present?
        direction = params[:direction] == "desc" ? "DESC" : "ASC"
        collection.order("#{params[:sort]} #{direction}")
      else
        collection.order(created_at: :desc)
      end
    end

    # Export to CSV with filters applied
    def export_to_excel(collection)
      require 'csv'
      
      file_name = "productos_#{Time.current.strftime('%Y%m%d_%H%M%S')}.csv"
      file_path = Rails.root.join("tmp", file_name)

      CSV.open(file_path, 'w', encoding: 'UTF-8', col_sep: ';') do |csv|
        # Headers
        csv << ['SKU', 'Nombre', 'Categoría', 'Tipo', 'Cantidad', 'Costo', 'Precio', 'Activo']

        # Data rows
        collection.includes(:product_category).each do |product|
          csv << [
            product.product_code,
            product.name,
            product.product_category&.name,
            product.product_type_before_type_cast,
            product.quantity,
            product.cost,
            product.price,
            product.is_active ? 'Sí' : 'No'
          ]
        end
      end

      send_file file_path, filename: file_name, type: 'text/csv; charset=utf-8'
    end
end