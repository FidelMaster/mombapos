class StockUnitMeasuresController < ApplicationController
  before_action :set_stock_unit_measure, only: %i[ show edit update destroy ]

  # GET /stock_unit_measures
  def index
    @stock_unit_measures = StockUnitMeasure.all
  end

  # GET /stock_unit_measures/1
  def show
  end

  # GET /stock_unit_measures/new
  def new
    @stock_unit_measure = StockUnitMeasure.new
  end

  # GET /stock_unit_measures/1/edit
  def edit
  end

  # POST /stock_unit_measures
  def create
    @stock_unit_measure = StockUnitMeasure.new(stock_unit_measure_params)
    @stock_unit_measure.tenant = Current.tenant

    if @stock_unit_measure.save
      redirect_to @stock_unit_measure, notice: "Stock unit measure was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /stock_unit_measures/1
  def update
    if @stock_unit_measure.update(stock_unit_measure_params)
      redirect_to @stock_unit_measure, notice: "Stock unit measure was successfully updated.", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /stock_unit_measures/1
  def destroy
    @stock_unit_measure.destroy!
    redirect_to stock_unit_measures_url, notice: "Stock unit measure was successfully destroyed.", status: :see_other
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_stock_unit_measure
      @stock_unit_measure = StockUnitMeasure.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def stock_unit_measure_params
      params.require(:stock_unit_measure).permit(:name, :is_active)
    end
end
