# Represents a single ACH file, storing its data and metadata.
class AchFile < ApplicationRecord
  belongs_to :user

  enum :status, { parsing: 0, completed: 1, failed: 2 }, prefix: true, default: :parsing
  enum :storage_type, { temporary: 0, permanent: 1 }, prefix: true, default: :temporary

  validates :status, presence: true
  validates :storage_type, presence: true

  def to_param
    uuid
  end
end
