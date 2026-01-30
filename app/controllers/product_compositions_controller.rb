class ProductCompositionsController < ApplicationController
  before_action :set_product
  before_action :set_product_composition

  def show
    redirect_to edit_product_product_composition_path(@product)
  end

  def edit
    @products = Product.where.not(id: @product.id).order(:name)
    @unit_measures = UnitMeasure.all.order(:name)
    @product_composition.product_composition_items.build if @product_composition.product_composition_items.empty?
  end

  def update
    if @product_composition.update(product_composition_params)
      redirect_to products_path, notice: "Receta de #{@product.name} actualizada correctamente."
    else
      @products = Product.where.not(id: @product.id).order(:name)
      @unit_measures = UnitMeasure.all.order(:name)
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_product
    @product = Product.find(params[:product_id])
  end

  def set_product_composition
    @product_composition = @product.product_composition || @product.create_product_composition(tenant: Current.tenant, name: "Receta #{@product.name}")
  end

  def product_composition_params
    params.require(:product_composition).permit(
      :name,
      product_composition_items_attributes: [:id, :product_id, :quantity, :unit_measure_id, :_destroy]
    )
  end
end
