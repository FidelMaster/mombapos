class RolesController < ApplicationController
  before_action :set_role, only: %i[ show edit update destroy ]
  
  authorize_resource

  AVAILABLE_SUBJECTS = {
    "Product" => "🍔 Menú / Productos",
    "Invoice" => "📄 Facturas",
    "Order" => "🛒 Pedidos",
    "Customer" => "👥 Clientes",
    "Branch" => "🏪 Sucursales",
    "Warehouse" => "📦 Almacenes",
    "User" => "👤 Usuarios",
    "Role" => "🔑 Roles y Permisos",
    "pos" => "⚡ Punto de Venta (POS)",
    "reports" => "📊 Reportes",
    "dashboard" => "🏦 Panel de Control"
  }.freeze

  AVAILABLE_ACTIONS = %w[read create update destroy manage].freeze

  helper_method :available_subjects, :available_actions

  def index
    @roles = manage_resource(Role.where(tenant_id: Current.tenant.id))
  end

  def show
  end

  def new
    @role = Role.new
  end

  def edit
  end

  def create
    @role = Role.new(role_params)
    @role.tenant = Current.tenant

    if @role.save
      save_permissions
      redirect_to roles_path, notice: "Rol creado exitosamente."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @role.update(role_params)
      save_permissions
      redirect_to roles_path, notice: "Rol actualizado exitosamente."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    # Do not allow deleting system roles if they are owner or admin, or currently used
    if %w[owner admin].include?(@role.name.downcase)
      redirect_to roles_path, alert: "No se pueden eliminar los roles del sistema (owner / admin)."
    elsif @role.users.any?
      redirect_to roles_path, alert: "No se puede eliminar este rol porque tiene usuarios asignados."
    else
      @role.destroy!
      redirect_to roles_url, notice: "Rol eliminado exitosamente.", status: :see_other
    end
  end

  private

  def set_role
    @role = Role.where(tenant_id: Current.tenant.id).find(params[:id])
  end

  def role_params
    params.require(:role).permit(:name)
  end

  def save_permissions
    @role.permissions.destroy_all
    if params[:permissions].present?
      permissions_hash = params[:permissions].to_unsafe_h rescue {}
      permissions_hash.each do |subject_class, actions|
        next unless AVAILABLE_SUBJECTS.key?(subject_class)
        Array(actions).each do |action|
          next unless AVAILABLE_ACTIONS.include?(action)
          @role.permissions.create!(action: action, subject_class: subject_class)
        end
      end
    end
  end

  def available_subjects
    AVAILABLE_SUBJECTS
  end

  def available_actions
    AVAILABLE_ACTIONS
  end
end
