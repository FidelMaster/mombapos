class LicenseModule < ApplicationRecord
  belongs_to :license
  belongs_to :app_module
end
