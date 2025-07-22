class AchInputFile < ApplicationRecord
  belongs_to :ach_file
  validates :source, presence: true
end
