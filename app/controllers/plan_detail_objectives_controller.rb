class PlanDetailObjectivesController < ApplicationController
  before_action :set_plan_detail_objective, only: %i[ show edit update destroy ]

  # GET /plan_detail_objectives
  def index
    @plan_detail_objectives = PlanDetailObjective.all
  end

  # GET /plan_detail_objectives/1
  def show
  end

  # GET /plan_detail_objectives/new
  def new
    @plan_detail_objective = PlanDetailObjective.new
  end

  # GET /plan_detail_objectives/1/edit
  def edit
  end

  # POST /plan_detail_objectives
  def create
    @plan_detail_objective = PlanDetailObjective.new(plan_detail_objective_params)

    if @plan_detail_objective.save
      redirect_to manage_plan_path(@plan_detail_objective.plan_detail.plan), notice: "Objetivo agregado."
    else
      redirect_to manage_plan_path(@plan_detail_objective.plan_detail.plan), alert: "Error al agregar objetivo."
    end
  end

  # PATCH/PUT /plan_detail_objectives/1
  def update
    if @plan_detail_objective.update(plan_detail_objective_params)
      redirect_to manage_plan_path(@plan_detail_objective.plan_detail.plan), notice: "Objetivo actualizado."
    else
      redirect_to manage_plan_path(@plan_detail_objective.plan_detail.plan), alert: "Error al actualizar objetivo."
    end
  end

  # DELETE /plan_detail_objectives/1
  def destroy
    plan = @plan_detail_objective.plan_detail.plan
    @plan_detail_objective.destroy!
    redirect_to manage_plan_path(plan), notice: "Objetivo eliminado."
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_plan_detail_objective
      @plan_detail_objective = PlanDetailObjective.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def plan_detail_objective_params
      params.require(:plan_detail_objective).permit(:plan_detail_id, :description, :is_active)
    end
end
