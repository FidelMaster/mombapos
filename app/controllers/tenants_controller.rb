class TenantsController < ApplicationController
  before_action :set_tenant, only: %i[ 
    show edit update destroy manage_modules update_modules 
    manage_users create_user toggle_user_status destroy_user toggle_active 
  ]

  # GET /tenants
  def index
    @tenants = Tenant.includes(:users).all.order(created_at: :desc)
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

  # PATCH /tenants/1/toggle_active
  def toggle_active
    new_status = !@tenant.is_active?
    @tenant.update_column(:is_active, new_status)
    status_label = new_status ? "activado" : "inactivado"
    redirect_back fallback_location: tenants_path, notice: "Tenant '#{@tenant.name}' #{status_label} correctamente."
  end

  # GET /tenants/1/manage_users
  def manage_users
    @tenant.ensure_default_roles
    @users = @tenant.users.order(created_at: :desc)
    @roles = @tenant.roles.order(:name)
    @new_user = @tenant.users.build(is_active: true)
  end

  # POST /tenants/1/create_user
  def create_user
    @tenant.ensure_default_roles
    @new_user = @tenant.users.build(tenant_user_params)

    # Sincronizar enum role si coincide con el rol seleccionado
    if @new_user.role_id.present?
      assigned_role = Role.find_by(id: @new_user.role_id)
      if assigned_role && User.roles.key?(assigned_role.name)
        @new_user.role = assigned_role.name
      end
    end

    if @new_user.save
      redirect_to manage_users_tenant_path(@tenant), notice: "Usuario '#{@new_user.email}' creado exitosamente para #{@tenant.name}."
    else
      @users = @tenant.users.where.not(id: nil).order(created_at: :desc)
      @roles = @tenant.roles.order(:name)
      render :manage_users, status: :unprocessable_entity
    end
  end

  # PATCH /tenants/1/toggle_user_status?user_id=X
  def toggle_user_status
    @user = @tenant.users.find(params[:user_id])
    new_status = !@user.is_active?
    @user.update_column(:is_active, new_status)
    status_label = new_status ? "activado" : "inactivado"
    redirect_back fallback_location: manage_users_tenant_path(@tenant), notice: "Usuario '#{@user.email}' #{status_label} correctamente."
  end

  # DELETE /tenants/1/destroy_user?user_id=X
  def destroy_user
    @user = @tenant.users.find(params[:user_id])
    @user.destroy!
    redirect_to manage_users_tenant_path(@tenant), notice: "Usuario eliminado correctamente."
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
      params.require(:tenant).permit(
        :uuid, :name, :email, :subdomain, :logo, :logo_url,
        :address, :phone, :city, :business_dni,
        :max_users, :max_invoices, :max_branches, :max_products,
        :default_currency, :timezone, :is_active, :license_id
      )
    end

    def tenant_user_params
      params.require(:user).permit(:email, :password, :password_confirmation, :role_id, :is_active)
    end
end
