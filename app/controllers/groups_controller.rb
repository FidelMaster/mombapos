class GroupsController < ApplicationController
  before_action :set_group, only: %i[ show edit update destroy manage ]

  # GET /groups
  def index
    @groups = Group.all
  end

  # GET /groups/1
  def show
  end

  # GET /groups/new
  def new
    @group = Group.new
  end

  # GET /groups/1/edit
  def edit
  end

  # GET /groups/1/manage
  def manage
    @group_members = @group.group_members.includes(:student)
    @group_tasks = @group.group_tasks
    @new_member = @group.group_members.build
    @new_task = @group.group_tasks.build
  end

  # POST /groups
  def create
    @group = Group.new(group_params)
    @group.tenant = Current.tenant

    if @group.save
      redirect_to @group, notice: "Group was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /groups/1
  def update
    if @group.update(group_params)
      redirect_to @group, notice: "Group was successfully updated.", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /groups/1
  def destroy
    @group.destroy!
    redirect_to groups_url, notice: "Group was successfully destroyed.", status: :see_other
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_group
      @group = Group.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def group_params
      params.require(:group).permit(:trainer_id, :name, :description, :execution_date, :end_date, :execution_hour, :status, :max_students, :duration_in_minutes, :price, :total_incomes)
    end
end
