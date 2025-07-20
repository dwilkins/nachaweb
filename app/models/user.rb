class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :api_keys, dependent: :destroy

    enum :role, { user: 0, admin: 1 }

  after_initialize :set_default_role, if: :new_record?

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  private

  def set_default_role
    self.role ||= :user
  end
end
