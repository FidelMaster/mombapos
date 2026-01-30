class PriceListItemsController < ApplicationController
  def index
    @price_lists = PriceList.where(is_active: true)

    if params[:price_list_id].present?
      @price_list = PriceList.find_by(id: params[:price_list_id])
    else
      @price_list = @price_lists.first
    end

    if @price_list
      @items = PriceListItem.where(price_list: @price_list)
                            .includes(:product)
                            .order('products.name ASC')
    else
      @items = []
    end
  end
    
  def update
    @item = PriceListItem.find(params[:id])
    if @item.update(price_list_item_params)
      respond_to do |format|
        format.html { redirect_to price_list_items_path(price_list_id: @item.price_list_id), notice: "Precio actualizado." }
        format.turbo_stream { redirect_to price_list_items_path(price_list_id: @item.price_list_id), notice: "Precio actualizado." }
      end
    else
      render :index, status: :unprocessable_entity
    end
  end

  private

  def price_list_item_params
    params.require(:price_list_item).permit(:price)
  end
end
