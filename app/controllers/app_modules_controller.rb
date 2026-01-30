class AppModulesController < ApplicationController
  before_action :set_app_module, only: %i[ show edit update destroy ]

  # GET /app_modules
  def index
    @app_modules = AppModule.all
  end

  # GET /app_modules/1
  def show
  end

  # GET /app_modules/new
  def new
    @app_module = AppModule.new
  end

  # GET /app_modules/1/edit
  def edit
  end

  # POST /app_modules
  def create
    @app_module = AppModule.new(app_module_params)

    if @app_module.save
      redirect_to @app_module, notice: "App module was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /app_modules/1
  def update
    if @app_module.update(app_module_params)
      redirect_to @app_module, notice: "App module was successfully updated.", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /app_modules/1
  def destroy
    @app_module.destroy!
    redirect_to app_modules_url, notice: "App module was successfully destroyed.", status: :see_other
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_app_module
      @app_module = AppModule.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def app_module_params
      params.require(:app_module).permit(:code, :name)
    end
end
