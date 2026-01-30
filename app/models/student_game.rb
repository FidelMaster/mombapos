class StudentGame < ApplicationRecord
  belongs_to :tenant
  belongs_to :student
end
