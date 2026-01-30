class ApplicationController < ActionController::Base
  include ResourceManageable
  
  before_action :authenticate_user!
  before_action :set_current_tenant

  layout :layout_by_resource

  helper_method :current_tenant

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

  def after_sign_in_path_for(resource)
    authenticated_root_path
  end
end
