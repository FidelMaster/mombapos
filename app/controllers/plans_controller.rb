class PlansController < ApplicationController
  before_action :set_plan, only: %i[ show edit update destroy manage ]

  # GET /plans
  def index
    @plans = Plan.all
  end

  # GET /plans/1
  def show
  end

  # GET /plans/new
  def new
    @plan = Plan.new
    load_form_collections
  end

  # GET /plans/1/edit
  def edit
    load_form_collections
  end

  # GET /plans/1/manage
  def manage
    @plan_details = @plan.plan_details.includes(:plan_detail_structures, :plan_detail_objectives)
    @plan_extra_controls = @plan.plan_extra_controls.includes(:plan_extra_control_details)
    @new_detail = @plan.plan_details.build
    @new_objective = PlanDetailObjective.new
    @new_structure = PlanDetailStructure.new
    @new_task = PlanDetailStructureTask.new
    @new_extra_control = @plan.plan_extra_controls.build
    @new_extra_control_detail = PlanExtraControlDetail.new
  end

  # POST /plans
  def create
    @plan = Plan.new(plan_params)
    @plan.tenant = Current.tenant

    if @plan.save
      redirect_to @plan, notice: "Plan was successfully created."
    else
      load_form_collections
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /plans/1
  def update
    if @plan.update(plan_params)
      redirect_to @plan, notice: "Plan was successfully updated.", status: :see_other
    else
      load_form_collections
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /plans/1
  def destroy
    @plan.destroy!
    redirect_to plans_url, notice: "Plan was successfully destroyed.", status: :see_other
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_plan
      @plan = Plan.find(params[:id])
    end

    def load_form_collections
      @trainers = Trainer.order(:name)
      @students = Student.order(:name)
    end

    # Only allow a list of trusted parameters through.
    def plan_params
      params.require(:plan).permit(:trainer_id, :student_id, :name, :description, :observation, :is_active, :total_duration_in_days, :tournament, :event, :event_date, :event_observation)
    end
end
