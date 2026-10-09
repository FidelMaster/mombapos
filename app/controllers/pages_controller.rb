class PagesController < ApplicationController
  layout "landing"
  # Permite que visitantes no autenticados vean la landing
  skip_before_action :authenticate_user!, only: [:home, :terms, :privacy, :support]
  
  # Si ya está autenticado y entra a la raíz, redirige a su panel
  before_action :redirect_if_authenticated, only: [:home]

  def home
    # Landing page principal
  end

  def terms; end
  def privacy; end
  def support; end

  private

  def redirect_if_authenticated
    redirect_to authenticated_root_path if user_signed_in?
  end
end