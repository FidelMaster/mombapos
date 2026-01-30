class GroupTasksController < ApplicationController
  before_action :set_group_task, only: %i[ show edit update destroy ]

  # GET /group_tasks
  def index
    @group_tasks = GroupTask.all
  end

  # GET /group_tasks/1
  def show
  end

  # GET /group_tasks/new
  def new
    @group_task = GroupTask.new
  end

  # GET /group_tasks/1/edit
  def edit
  end

  # POST /group_tasks
  def create
    @group_task = GroupTask.new(group_task_params)

    if @group_task.save
      redirect_to manage_group_path(@group_task.group), notice: "Tarea creada correctamente."
    else
      redirect_to manage_group_path(@group_task.group), alert: "Error al crear tarea."
    end
  end

  # PATCH/PUT /group_tasks/1
  def update
    if @group_task.update(group_task_params)
      redirect_to manage_group_path(@group_task.group), notice: "Tarea actualizada."
    else
      redirect_to manage_group_path(@group_task.group), alert: "Error al actualizar."
    end
  end

  # DELETE /group_tasks/1
  def destroy
    group = @group_task.group
    @group_task.destroy!
    redirect_to manage_group_path(group), notice: "Tarea eliminada.", status: :see_other
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_group_task
      @group_task = GroupTask.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def group_task_params
      params.require(:group_task).permit(:group_id, :name, :description, :observation, :start_date, :end_date)
    end
end
