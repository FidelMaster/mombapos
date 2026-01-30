class PriceListsController < ApplicationController
  before_action :set_price_list, only: %i[ show edit update destroy ]

  # GET /price_lists
  def index
    @price_lists = PriceList.all
  end

  # GET /price_lists/1
  def show
  end

  # GET /price_lists/new
  def new
    @price_list = PriceList.new
  end

  # GET /price_lists/1/edit
  def edit
  end

  def price_control
  end

  # POST /price_lists
  def create
    @price_list = PriceList.new(price_list_params)
    @price_list.tenant = Current.tenant

    if @price_list.save
      redirect_to @price_list, notice: "Price list was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /price_lists/1
  def update
    if @price_list.update(price_list_params)
      redirect_to @price_list, notice: "Price list was successfully updated.", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /price_lists/1
  def destroy
    @price_list.destroy!
    redirect_to price_lists_url, notice: "Price list was successfully destroyed.", status: :see_other
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_price_list
      @price_list = PriceList.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def price_list_params
      params.require(:price_list).permit(:name, :currency, :is_active)
    end
end
