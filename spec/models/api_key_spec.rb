require 'rails_helper'

RSpec.describe ApiKey, type: :model do
  let(:user) { User.create!(email_address: "test@example.com", password: "password") }

  it "is valid with a user and description" do
    api_key = described_class.new(user:, description: "Test Key")
    expect(api_key).to be_valid
  end

  it "is invalid without a description" do
    api_key = described_class.new(user:, description: nil)
    expect(api_key).not_to be_valid
    expect(api_key.errors[:description]).to include("can't be blank")
  end

  it "is invalid without a user" do
    api_key = described_class.new(description: "Test Key")
    expect(api_key).not_to be_valid
    expect(api_key.errors[:user]).to include("must exist")
  end

  it "generates a token on creation" do
    api_key = described_class.create(user:, description: "Test Key")
    expect(api_key.token).to be_present
  end

  it "belongs to a user" do
    assoc = described_class.reflect_on_association(:user)
    expect(assoc.macro).to eq :belongs_to
  end
end
