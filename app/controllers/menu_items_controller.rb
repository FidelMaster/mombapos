class MenuItemsController < ApplicationController
  before_action :set_menu_item, only: %i[ show edit update destroy ]

  # GET /menu_items
  def index
    @menu_items = MenuItem.all
  end

  # GET /menu_items/1
  def show
  end

  # GET /menu_items/new
  def new
    @menu_item = MenuItem.new
  end

  # GET /menu_items/1/edit
  def edit
  end

  # POST /menu_items
  def create
    @menu_item = MenuItem.new(menu_item_params)

    if @menu_item.save
      redirect_to @menu_item, notice: "Menu item was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /menu_items/1
  def update
    if @menu_item.update(menu_item_params)
      redirect_to @menu_item, notice: "Menu item was successfully updated.", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /menu_items/1
  def destroy
    @menu_item.destroy!
    redirect_to menu_items_url, notice: "Menu item was successfully destroyed.", status: :see_other
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_menu_item
      @menu_item = MenuItem.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def menu_item_params
      params.require(:menu_item).permit(:key, :label, :icon, :path, :section, :position, :item_type, :parent_id)
    end
end
