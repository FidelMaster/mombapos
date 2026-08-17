class Permission < ApplicationRecord
  belongs_to :role

  validates :action, presence: true
  validates :subject_class, presence: true
end
