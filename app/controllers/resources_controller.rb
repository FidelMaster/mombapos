class ResourcesController < ApplicationController
  before_action :set_resource, only: %i[ show edit update destroy ]

  # GET /resources
  def index
    @resources = Resource.all
  end

  # GET /resources/1
  def show
  end

  # GET /resources/new
  def new
    @resource = Resource.new
    load_form_collections
  end

  # GET /resources/1/edit
  def edit
    load_form_collections
  end

  # POST /resources
  def create
    @resource = Resource.new(resource_params)
    @resource.tenant = Current.tenant

    if @resource.save
      redirect_to @resource, notice: "Resource was successfully created."
    else
      load_form_collections
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /resources/1
  def update
    if @resource.update(resource_params)
      redirect_to @resource, notice: "Resource was successfully updated.", status: :see_other
    else
      load_form_collections
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /resources/1
  def destroy
    @resource.destroy!
    redirect_to resources_url, notice: "Resource was successfully destroyed.", status: :see_other
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_resource
      @resource = Resource.find(params[:id])
    end

    def load_form_collections
      @levels = Level.order(:name)
    end

    # Only allow a list of trusted parameters through.
    def resource_params
      params.require(:resource).permit(:level_id, :name, :resource_type, :location_url, :is_active)
    end
end
