class PlanDetailStructuresController < ApplicationController
  before_action :set_plan_detail_structure, only: %i[ update destroy ]

  def create
    @plan_detail_structure = PlanDetailStructure.new(plan_detail_structure_params)
    if @plan_detail_structure.save
      redirect_to manage_plan_path(@plan_detail_structure.plan_detail.plan), notice: "Tema agregado."
    else
      redirect_to manage_plan_path(@plan_detail_structure.plan_detail.plan), alert: "Error al agregar tema."
    end
  end

  def update
    if @plan_detail_structure.update(plan_detail_structure_params)
      redirect_to manage_plan_path(@plan_detail_structure.plan_detail.plan), notice: "Tema actualizado."
    else
      redirect_to manage_plan_path(@plan_detail_structure.plan_detail.plan), alert: "Error al actualizar tema."
    end
  end

  def destroy
    plan = @plan_detail_structure.plan_detail.plan
    @plan_detail_structure.destroy!
    redirect_to manage_plan_path(plan), notice: "Tema eliminado."
  end

  private

  def set_plan_detail_structure
    @plan_detail_structure = PlanDetailStructure.find(params[:id])
  end

  def plan_detail_structure_params
    params.require(:plan_detail_structure).permit(:plan_detail_id, :title)
  end
end
