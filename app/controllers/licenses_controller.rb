class LicensesController < ApplicationController
  before_action :set_license, only: %i[ show edit update destroy manage_modules update_modules ]

  # GET /licenses
  def index
    @licenses = License.all
  end

  # GET /licenses/1
  def show
  end

  # GET /licenses/new
  def new
    @license = License.new
  end

  # GET /licenses/1/edit
  def edit
  end

  # POST /licenses
  def create
    @license = License.new(license_params)

    if @license.save
      redirect_to @license, notice: "License was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /licenses/1
  def update
    if @license.update(license_params)
      redirect_to @license, notice: "License was successfully updated.", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # GET /licenses/1/manage_modules
  def manage_modules
    @app_modules = AppModule.all
    @license_module_ids = @license.app_modules.pluck(:id)
  end

  # POST /licenses/1/update_modules
  def update_modules
    module_ids = params[:module_ids] || []
    @license.app_module_ids = module_ids
    redirect_to licenses_path, notice: "Módulos de la licencia actualizados correctamente."
  end

  # DELETE /licenses/1
  def destroy
    @license.destroy!
    redirect_to licenses_url, notice: "License was successfully destroyed.", status: :see_other
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_license
      @license = License.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def license_params
      params.require(:license).permit(:name, :price)
    end
end
