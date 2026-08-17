class UsersController < ApplicationController
  before_action :set_user, only: %i[ show edit update destroy ]
  
  authorize_resource

  def index
    @users = manage_resource(User.where(tenant_id: Current.tenant.id))
  end

  def show
  end

  def new
    @user = User.new
  end

  def edit
  end

  def create
    @user = User.new(user_params)
    @user.tenant = Current.tenant

    if @user.save
      redirect_to users_path, notice: "Usuario creado exitosamente."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    params_to_update = user_params
    if params_to_update[:password].blank?
      params_to_update.delete(:password)
      params_to_update.delete(:password_confirmation)
    end

    if @user.update(params_to_update)
      redirect_to users_path, notice: "Usuario actualizado exitosamente."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @user.destroy!
    redirect_to users_url, notice: "Usuario eliminado exitosamente.", status: :see_other
  end

  private

  def set_user
    @user = User.where(tenant_id: Current.tenant.id).find(params[:id])
  end

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation, :role_id, :is_active)
  end
end
