class AchRecord < ApplicationRecord
  belongs_to :ach_file, dependent: :destroy
end
