# Represents a single ACH file, storing its data and metadata.
class AchFile < ApplicationRecord
  belongs_to :user
  has_many :ach_input_files, dependent: :destroy
  accepts_nested_attributes_for :ach_input_files
  has_many :ach_records, dependent: :destroy

  enum :status, { parsing: 0, completed: 1, failed: 2 }
  enum :storage_type, { temporary: 0, permanent: 1 }

  validates :user, presence: true
  validates :status, presence: true
  validates :storage_type, presence: true

  def to_param
    uuid
  end
end
