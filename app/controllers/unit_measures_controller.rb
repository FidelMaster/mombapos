class UnitMeasuresController < ApplicationController
  before_action :set_unit_measure, only: %i[ show edit update destroy ]

  # GET /unit_measures
  def index
    @unit_measures = UnitMeasure.all
  end

  # GET /unit_measures/1
  def show
  end

  # GET /unit_measures/new
  def new
    @unit_measure = UnitMeasure.new
  end

  # GET /unit_measures/1/edit
  def edit
  end

  # POST /unit_measures
  def create
    @unit_measure = UnitMeasure.new(unit_measure_params)
    @unit_measure.tenant = Current.tenant

    if @unit_measure.save
      redirect_to @unit_measure, notice: "Unit measure was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /unit_measures/1
  def update
    if @unit_measure.update(unit_measure_params)
      redirect_to @unit_measure, notice: "Unit measure was successfully updated.", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /unit_measures/1
  def destroy
    @unit_measure.destroy!
    redirect_to unit_measures_url, notice: "Unit measure was successfully destroyed.", status: :see_other
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_unit_measure
      @unit_measure = UnitMeasure.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def unit_measure_params
      params.require(:unit_measure).permit(:name, :abbreviation)
    end
end
