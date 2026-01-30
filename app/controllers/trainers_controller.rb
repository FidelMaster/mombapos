class TrainersController < ApplicationController
  before_action :set_trainer, only: %i[ show edit update destroy ]

  # GET /trainers
  def index
    @trainers = Trainer.all
  end

  # GET /trainers/1
  def show
  end

  # GET /trainers/new
  def new
    @trainer = Trainer.new
    load_form_collections
  end

  # GET /trainers/1/edit
  def edit
    load_form_collections
  end

  # POST /trainers
  def create
    @trainer = Trainer.new(trainer_params)
    @trainer.tenant = Current.tenant

    if @trainer.save
      redirect_to @trainer, notice: "Trainer was successfully created."
    else
      load_form_collections
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /trainers/1
  def update
    if @trainer.update(trainer_params)
      redirect_to @trainer, notice: "Trainer was successfully updated.", status: :see_other
    else
      load_form_collections
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /trainers/1
  def destroy
    @trainer.destroy!
    redirect_to trainers_url, notice: "Trainer was successfully destroyed.", status: :see_other
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_trainer
      @trainer = Trainer.find(params[:id])
    end

    def load_form_collections
      @departments = Department.order(:name)
      @municipalities = Municipality.order(:name)
      @users = User.order(:email) 
    end

    # Only allow a list of trusted parameters through.
    def trainer_params
      params.require(:trainer).permit(:user_id, :name, :email, :phone, :rate_per_hour, :hire_date, :department_id, :municipality_id)
    end
end
