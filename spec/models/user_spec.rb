require 'rails_helper'

RSpec.describe User, type: :model do
  subject(:user) { described_class.new(email_address: "test@example.com", password: "password") }

  it "is valid with valid attributes" do
    expect(user).to be_valid
  end

  it "is not valid without an email address" do
    user.email_address = nil
    expect(user).not_to be_valid
  end

  it "is not valid without a password" do
    user.password = nil
    expect(user).not_to be_valid
  end

  it "is not valid with a duplicate email address" do
    described_class.create!(email_address: user.email_address, password: user.password)
    expect(user).not_to be_valid
  end
end
