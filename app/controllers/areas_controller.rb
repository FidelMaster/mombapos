class AreasController < ApplicationController
  before_action :set_area, only: %i[ show edit update destroy ]

  # GET /areas
  def index
    @areas = Area.all
  end

  # GET /areas/1
  def show
  end

  # GET /areas/new
  def new
    @area = Area.new
  end

  # GET /areas/1/edit
  def edit
  end

  # POST /areas
  def create
    @area = Area.new(area_params)
    @area.tenant = Current.tenant

    if @area.save
      redirect_to areas_path, notice: "Área creada exitosamente."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /areas/1
  def update
    if @area.update(area_params)
      redirect_to areas_path, notice: "Área actualizada exitosamente."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /areas/1
  def destroy
    @area.destroy!
    redirect_to areas_url, notice: "Area was successfully destroyed.", status: :see_other
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_area
      @area = Area.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def area_params
      params.require(:area).permit(:name, :is_active, :color)
    end
end
