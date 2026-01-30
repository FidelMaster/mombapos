class PriceListItem < ApplicationRecord
  belongs_to :price_list
  belongs_to :product
end
