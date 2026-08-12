class CustomersController < ApplicationController
  before_action :set_customer, only: %i[ show edit update destroy ]

  # GET /customers
  def index
    @customers = manage_resource(Customer.all)
  end

  # GET /customers/1
  def show
  end

  # GET /customers/new
  def new
    @customer = Customer.new(is_active: true )
    load_form_collections
  end

  # GET /customers/1/edit
  def edit
    load_form_collections
  end

  # POST /customers
  def create
    @customer = Customer.new(customer_params)
    @customer.tenant = Current.tenant

    if @customer.save
      redirect_to @customer, notice: "Customer was successfully created."
    else
      load_form_collections
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /customers/1
  def update
    if @customer.update(customer_params)
      redirect_to @customer, notice: "Customer was successfully updated.", status: :see_other
    else
      load_form_collections
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /customers/1
  def destroy
    @customer.destroy!
    redirect_to customers_url, notice: "Customer was successfully destroyed.", status: :see_other
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_customer
      @customer = Customer.find(params[:id])
    end

    def load_form_collections
      @departments = Department.order(:name)
      @municipalities = Municipality.order(:name)
    end


    # Only allow a list of trusted parameters through.
    def customer_params
      params.require(:customer).permit(:name, :address, :department_id, :municipality_id, :contact_name, :contact_email, :contact_phone, :credit_limit, :is_tax_exempt, :is_active)
    end
end
