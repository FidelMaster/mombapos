class License < ApplicationRecord
  has_many :license_modules, dependent: :destroy
  has_many :app_modules, through: :license_modules
end
