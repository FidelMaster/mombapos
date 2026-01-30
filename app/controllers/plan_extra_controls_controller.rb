class PlanExtraControlsController < ApplicationController
  before_action :set_plan_extra_control, only: %i[ update destroy ]

  def create
    @plan_extra_control = PlanExtraControl.new(plan_extra_control_params)
    if @plan_extra_control.save
      redirect_to manage_plan_path(@plan_extra_control.plan), notice: "Control extra agregado."
    else
      redirect_to manage_plan_path(@plan_extra_control.plan), alert: "Error al agregar control."
    end
  end

  def update
    if @plan_extra_control.update(plan_extra_control_params)
      redirect_to manage_plan_path(@plan_extra_control.plan), notice: "Control actualizado."
    else
      redirect_to manage_plan_path(@plan_extra_control.plan), alert: "Error al actualizar."
    end
  end

  def destroy
    plan = @plan_extra_control.plan
    @plan_extra_control.destroy!
    redirect_to manage_plan_path(plan), notice: "Control eliminado."
  end

  private

  def set_plan_extra_control
    @plan_extra_control = PlanExtraControl.find(params[:id])
  end

  def plan_extra_control_params
    params.require(:plan_extra_control).permit(:plan_id, :control_type)
  end
end
