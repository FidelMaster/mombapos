class PlanExtraControlDetailsController < ApplicationController
  before_action :set_plan_extra_control_detail, only: %i[ show edit update destroy ]

  # GET /plan_extra_control_details
  def index
    @plan_extra_control_details = PlanExtraControlDetail.all
  end

  # GET /plan_extra_control_details/1
  def show
  end

  # GET /plan_extra_control_details/new
  def new
    @plan_extra_control_detail = PlanExtraControlDetail.new
  end

  # GET /plan_extra_control_details/1/edit
  def edit
  end

  # POST /plan_extra_control_details
  def create
    @plan_extra_control_detail = PlanExtraControlDetail.new(plan_extra_control_detail_params)

    if @plan_extra_control_detail.save
      redirect_to manage_plan_path(@plan_extra_control_detail.plan_extra_control.plan), notice: "Detalle de control agregado."
    else
      redirect_to manage_plan_path(@plan_extra_control_detail.plan_extra_control.plan), alert: "Error al agregar detalle."
    end
  end

  # PATCH/PUT /plan_extra_control_details/1
  def update
    if @plan_extra_control_detail.update(plan_extra_control_detail_params)
      redirect_to manage_plan_path(@plan_extra_control_detail.plan_extra_control.plan), notice: "Detalle actualizado."
    else
      redirect_to manage_plan_path(@plan_extra_control_detail.plan_extra_control.plan), alert: "Error al actualizar."
    end
  end

  # DELETE /plan_extra_control_details/1
  def destroy
    plan = @plan_extra_control_detail.plan_extra_control.plan
    @plan_extra_control_detail.destroy!
    redirect_to manage_plan_path(plan), notice: "Detalle eliminado."
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_plan_extra_control_detail
      @plan_extra_control_detail = PlanExtraControlDetail.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def plan_extra_control_detail_params
      params.require(:plan_extra_control_detail).permit(:plan_extra_control_id, :observation)
    end
end
