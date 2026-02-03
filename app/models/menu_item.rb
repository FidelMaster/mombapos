class MenuItem < ApplicationRecord
  ITEM_TYPES = %w[link dropdown divider].freeze

  validates :key, presence: true, uniqueness: true
  validates :label, presence: true
  validates :item_type, inclusion: { in: ITEM_TYPES }

  belongs_to :parent,
             class_name: 'MenuItem',
             optional: true

  has_many :children,
           class_name: 'MenuItem',
           foreign_key: :parent_id,
           dependent: :destroy

  has_many :app_modules_menu_items, dependent: :destroy
  has_many :app_modules, through: :app_modules_menu_items

  scope :roots, -> { where(parent_id: nil).order(:section, :position) }
end
