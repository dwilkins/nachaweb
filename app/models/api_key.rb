class ApiKey < ApplicationRecord
  belongs_to :user
  has_secure_token

  validates :description, presence: true

  scope :active, -> { where(revoked_at: nil).where("expires_at IS NULL OR expires_at > ?", Time.current) }

  def active?
    revoked_at.nil? && (expires_at.nil? || expires_at > Time.current)
  end

  def revoked!
    update!(revoked_at: Time.current)
  end
end
