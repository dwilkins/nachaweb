class AchInputFile < ApplicationRecord
  belongs_to :ach_file
  has_one_attached :file_data

  validates :source, presence: true, unless: -> { file_data.attached? }
  validates :file_data, presence: true, if: -> { source.blank? }
end
