class Municipality < ApplicationRecord
  belongs_to :department

  has_many :customer_address
  has_many :customer
end
