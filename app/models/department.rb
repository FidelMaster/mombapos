class Department < ApplicationRecord
  belongs_to :country
  has_many :municipality
  has_many :customer_address
  has_many :customer
end
