class ProductComposition < ApplicationRecord
  belongs_to :tenant
  belongs_to :product
  has_many :product_composition_items, dependent: :destroy
  accepts_nested_attributes_for :product_composition_items, allow_destroy: true, reject_if: :all_blank

  default_scope { where(tenant_id: Current.tenant.id) }
end
