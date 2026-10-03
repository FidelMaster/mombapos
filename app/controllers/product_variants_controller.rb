class ProductVariantsController < ApplicationController
  before_action :set_product
  before_action :set_variant, only: %i[show update destroy]

  # GET /products/:product_id/variants.json
  def index
    variants = @product.product_variants.ordered.with_attached_photos
    variants = variants.active if params[:all].blank?

    respond_to do |format|
      format.json do
        render json: {
          product: { id: @product.id, name: @product.name, price: @product.price.to_f },
          variants: variants.map do |variant|
            variant.as_option_json.merge(
              photo_url: (url_for(variant.main_photo) if variant.main_photo)
            )
          end
        }
      end
      format.html { redirect_to @product }
    end
  end

  # GET /products/:product_id/variants/:id
  def show
    respond_to do |format|
      format.json { render json: @variant.as_option_json }
      format.html { redirect_to @product }
    end
  end

  # POST /products/:product_id/variants
  def create
    @variant = @product.product_variants.build(variant_params)
    @variant.tenant_id = Current.tenant&.id || @product.tenant_id

    respond_to do |format|
      if @variant.save
        format.html { redirect_to @product, notice: "Variante creada exitosamente." }
        format.json { render json: @variant.as_option_json, status: :created }
      else
        format.html { redirect_to @product, alert: @variant.errors.full_messages.to_sentence }
        format.json { render json: { errors: @variant.errors }, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /products/:product_id/variants/:id
  def update
    respond_to do |format|
      if @variant.update(variant_params)
        format.html { redirect_to @product, notice: "Variante actualizada exitosamente." }
        format.json { render json: @variant.as_option_json, status: :ok }
      else
        format.html { redirect_to @product, alert: @variant.errors.full_messages.to_sentence }
        format.json { render json: { errors: @variant.errors }, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /products/:product_id/variants/:id
  def destroy
    @variant.destroy
    respond_to do |format|
      format.html { redirect_to @product, notice: "Variante eliminada exitosamente." }
      format.json { head :no_content }
    end
  end

  private

  def set_product
    @product = Product.find(params[:product_id])
  end

  def set_variant
    @variant = @product.product_variants.find(params[:id])
  end

  def variant_params
    params.require(:product_variant).permit(
      :sku, :variant_name, :metal_type, :karat, :size,
      :weight_grams, :cost, :price, :stock_quantity, :is_active, photos: []
    )
  end
end
