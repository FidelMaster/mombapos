class TenantsController < ApplicationController
  before_action :set_tenant, only: %i[ show edit update destroy manage_modules update_modules ]

  # GET /tenants
  def index
    @tenants = Tenant.all
  end

  # GET /tenants/1
  def show
  end

  # GET /tenants/new
  def new
    @tenant = Tenant.new
  end

  # GET /tenants/1/edit
  def edit
  end

  # POST /tenants
  def create
    @tenant = Tenant.new(tenant_params)

    if @tenant.save
      redirect_to @tenant, notice: "Tenant was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /tenants/1
  def update
    if @tenant.update(tenant_params)
      redirect_to @tenant, notice: "Tenant was successfully updated.", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # GET /tenants/1/manage_modules
  def manage_modules
    @app_modules = AppModule.all
    @tenant_module_ids = @tenant.app_modules.pluck(:id)
  end

  # POST /tenants/1/update_modules
  def update_modules
    module_ids = params[:module_ids] || []
    @tenant.app_module_ids = module_ids
    # Ensure enabled is true for all (if column matters)
    @tenant.tenant_modules.update_all(enabled: true)
    redirect_to tenants_path, notice: "Módulos del tenant actualizados correctamente."
  end

  # DELETE /tenants/1
  def destroy
    @tenant.destroy!
    redirect_to tenants_url, notice: "Tenant was successfully destroyed.", status: :see_other
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_tenant
      @tenant = Tenant.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def tenant_params
      params.require(:tenant).permit(:uuid, :name, :email, :subdomain, :logo_url, :max_users, :max_invoices, :max_branches, :max_products, :default_currency, :timezone, :is_active, :license_id)
    end
end
