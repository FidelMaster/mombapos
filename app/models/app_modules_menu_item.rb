class AppModulesMenuItem < ApplicationRecord
  belongs_to :app_module
  belongs_to :menu_item
end
