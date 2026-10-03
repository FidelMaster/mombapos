class ProductVariant < ApplicationRecord
  ALLOWED_PHOTO_TYPES = %w[image/jpeg image/png image/webp].freeze
  MAX_PHOTO_SIZE      = 5.megabytes
  MAX_PHOTOS          = 8

  belongs_to :tenant
  belongs_to :product
  has_many :order_items, dependent: :restrict_with_error
  has_many :invoice_items, dependent: :nullify

  alias_attribute :stock_available, :stock_quantity

  # Fotos de la pieza (servicio configurado en config/storage.yml → S3 en producción).
  has_many_attached :photos

  default_scope { where(tenant_id: Current.tenant&.id) }

  scope :active, -> { where(is_active: true) }
  scope :ordered, -> { order(:variant_name, :sku) }

  before_validation :assign_tenant, on: :create
  before_validation :normalize_sku
  before_validation :build_variant_name

  validates :sku, presence: true, uniqueness: { scope: :tenant_id, case_sensitive: false }
  validates :weight_grams, :cost, :price, numericality: { greater_than_or_equal_to: 0 }
  validates :stock_quantity, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validate  :product_belongs_to_same_tenant
  validate  :photos_are_valid

  # "Oro 14K Amarillo - Talla 7 · SKU AN-001"
  def display_name
    [variant_name.presence || product&.name, "SKU #{sku}"].compact.join(" · ")
  end

  def main_photo
    photos.first if photos.attached?
  end

  def decrease_stock!(qty)
    decrement!(:stock_quantity, qty.to_d)
  end

  def increase_stock!(qty)
    increment!(:stock_quantity, qty.to_d)
  end

  def as_option_json
    {
      id: id,
      sku: sku,
      name: variant_name,
      label: display_name,
      metal_type: metal_type,
      karat: karat,
      size: size,
      weight_grams: weight_grams.to_f,
      price: price.to_f,
      stock_quantity: stock_quantity.to_f,
      stock_available: stock_quantity.to_f
    }
  end

  private

  def assign_tenant
    self.tenant_id ||= product&.tenant_id || Current.tenant&.id
  end

  def normalize_sku
    self.sku = sku.to_s.strip.upcase.presence
  end

  # Si no se captura un nombre, se arma a partir de los atributos de la joya.
  def build_variant_name
    return if variant_name.present?

    parts = [metal_type, karat&.upcase].compact_blank.join(" ")
    parts = [parts.presence, (size.present? ? "Talla #{size}" : nil)].compact.join(" - ")
    self.variant_name = parts.presence
  end

  def product_belongs_to_same_tenant
    return if product.nil? || tenant_id.nil?

    errors.add(:product, "no pertenece a la empresa actual") if product.tenant_id != tenant_id
  end

  def photos_are_valid
    return unless photos.attached?

    errors.add(:photos, "no pueden ser más de #{MAX_PHOTOS}") if photos.size > MAX_PHOTOS

    photos.each do |photo|
      unless ALLOWED_PHOTO_TYPES.include?(photo.content_type)
        errors.add(:photos, "#{photo.filename}: formato no permitido (JPG, PNG o WEBP)")
      end
      if photo.byte_size > MAX_PHOTO_SIZE
        errors.add(:photos, "#{photo.filename}: excede #{MAX_PHOTO_SIZE / 1.megabyte} MB")
      end
    end
  end
end
