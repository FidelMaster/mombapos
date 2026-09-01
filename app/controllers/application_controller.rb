class ApplicationController < ActionController::Base
  include ResourceManageable
  
  before_action :authenticate_user!
  before_action :set_current_tenant

  rescue_from CanCan::AccessDenied do |exception|
    if user_signed_in?
      redirect_to authenticated_root_path, alert: "No tienes autorización para acceder a este recurso."
    else
      redirect_to new_user_session_path, alert: "Tu sesión ha expirado. Por favor inicia sesión nuevamente."
    end
  end

  layout :layout_by_resource

  helper_method :current_tenant

  protected

  def after_sign_in_path_for(resource)
    authenticated_root_path
  end

  def after_sign_out_path_for(resource_or_scope)
    new_user_session_path
  end

  private

  def set_current_tenant
    Current.tenant = current_user&.tenant
  end

  def current_tenant
    Current.tenant
  end

  def layout_by_resource
    devise_controller? ? "auth" : "application"
  end
end