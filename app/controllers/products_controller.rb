class ProductsController < ApplicationController
  before_action :set_product, only: %i[ show edit update destroy ]

  # GET /products
  def index
    @products = manage_resource(Product.all)
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
    if @product.update(product_params)
      redirect_to @product, notice: "Product was successfully updated.", status: :see_other
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
        :stock_unit_measure_id, 
        :sale_unit_measure_id, 
        :is_active,
        :price,
        :supplier_id,
        warehouse_stocks_attributes: [:id, :warehouse_id, :stock_available],
        price_list_items_attributes: [:id, :price_list_id, :price]
      )
    end
end
