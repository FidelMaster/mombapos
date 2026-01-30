class PlanDetailStructureTasksController < ApplicationController
  before_action :set_structure_task, only: %i[ update destroy ]

  def create
    @structure_task = PlanDetailStructureTask.new(structure_task_params)
    if @structure_task.save
      redirect_to manage_plan_path(@structure_task.plan_detail_structure.plan_detail.plan), notice: "Accion agregada."
    else
      redirect_to manage_plan_path(@structure_task.plan_detail_structure.plan_detail.plan), alert: "Error al agregar accion."
    end
  end

  def update
    if @structure_task.update(structure_task_params)
      redirect_to manage_plan_path(@structure_task.plan_detail_structure.plan_detail.plan), notice: "Accion actualizada."
    else
      redirect_to manage_plan_path(@structure_task.plan_detail_structure.plan_detail.plan), alert: "Error al actualizar accion."
    end
  end

  def destroy
    plan = @structure_task.plan_detail_structure.plan_detail.plan
    @structure_task.destroy!
    redirect_to manage_plan_path(plan), notice: "Accion eliminada."
  end

  private

  def set_structure_task
    @structure_task = PlanDetailStructureTask.find(params[:id])
  end

  def structure_task_params
    params.require(:plan_detail_structure_task).permit(:plan_detail_structure_id, :turn, :description, :percentage, :is_complete)
  end
end
