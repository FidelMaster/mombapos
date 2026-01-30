class PlanDetailsController < ApplicationController
  before_action :set_plan_detail, only: %i[ show edit update destroy ]

  # GET /plan_details
  def index
    @plan_details = PlanDetail.all
  end

  # GET /plan_details/1
  def show
  end

  # GET /plan_details/new
  def new
    @plan_detail = PlanDetail.new
  end

  # GET /plan_details/1/edit
  def edit
  end

  # POST /plan_details
  def create
    @plan_detail = PlanDetail.new(plan_detail_params)

    if @plan_detail.save
      redirect_to manage_plan_path(@plan_detail.plan), notice: "Fase agregada."
    else
      redirect_to manage_plan_path(@plan_detail.plan), alert: "Error al agregar fase."
    end
  end

  # PATCH/PUT /plan_details/1
  def update
    if @plan_detail.update(plan_detail_params)
      redirect_to manage_plan_path(@plan_detail.plan), notice: "Fase actualizada."
    else
      redirect_to manage_plan_path(@plan_detail.plan), alert: "Error al actualizar fase."
    end
  end

  # DELETE /plan_details/1
  def destroy
    plan = @plan_detail.plan
    @plan_detail.destroy!
    redirect_to manage_plan_path(plan), notice: "Fase eliminada."
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_plan_detail
      @plan_detail = PlanDetail.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def plan_detail_params
      params.require(:plan_detail).permit(:plan_id, :name, :duration_in_days)
    end
end
