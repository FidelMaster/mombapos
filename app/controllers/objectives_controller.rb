class ObjectivesController < ApplicationController
  before_action :set_objective, only: %i[ show edit update destroy ]

  # GET /objectives
  def index
    @objectives = Objective.all
  end

  # GET /objectives/1
  def show
  end

  # GET /objectives/new
  def new
    @objective = Objective.new
  end

  # GET /objectives/1/edit
  def edit
  end

  # POST /objectives
  def create
    @objective = Objective.new(objective_params)

    if @objective.save
      redirect_to @objective, notice: "Objective was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /objectives/1
  def update
    if @objective.update(objective_params)
      redirect_to @objective, notice: "Objective was successfully updated.", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /objectives/1
  def destroy
    @objective.destroy!
    redirect_to objectives_url, notice: "Objective was successfully destroyed.", status: :see_other
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_objective
      @objective = Objective.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def objective_params
      params.require(:objective).permit(:tenant_id, :name)
    end
end
