class AchInputFile < ApplicationRecord
  belongs_to :ach_file
  has_one_attached :file_data

  enum :modality, { file_upload: 0, pasted_text: 1, url: 2 }
  enum :format, { ach: 0, json: 1, markdown: 2 }

  validates :source, presence: true, unless: -> { file_data.attached? }
  validates :file_data, presence: true, if: -> { source.blank? }
end
