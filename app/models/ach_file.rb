class AchFile < ApplicationRecord
  belongs_to :user

  enum status: { parsing: 0, completed: 1, failed: 2 }, _prefix: true
  enum storage_type: { temporary: 0, permanent: 1 }, _prefix: true

  validates :status, presence: true
  validates :storage_type, presence: true

  def to_param
    uuid
  end
end
