class CustomerAddress < ApplicationRecord
  belongs_to :customer
  belongs_to :department
  belongs_to :municipality
end
