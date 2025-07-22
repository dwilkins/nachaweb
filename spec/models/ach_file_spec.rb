require 'rails_helper'

RSpec.describe AchFile, type: :model do
  let(:user) { User.create!(email_address: "test@example.com", password: "password") }

  it "is valid with a user" do
    ach_file = described_class.new(user:)
    expect(ach_file).to be_valid
  end

  it "is invalid without a user" do
    ach_file = described_class.new(user: nil)
    expect(ach_file).not_to be_valid
    expect(ach_file.errors[:user]).to include("must exist")
  end

  it "has a default status of 'parsing'" do
    ach_file = described_class.new(user:)
    expect(ach_file.status).to eq("parsing")
    expect(ach_file.parsing?).to be true
  end

  it "has a default storage_type of 'temporary'" do
    ach_file = described_class.new(user:)
    expect(ach_file.storage_type).to eq("temporary")
    expect(ach_file.temporary?).to be true
  end

  it "generates a uuid on creation" do
    ach_file = described_class.create!(user:)
    expect(ach_file.uuid).to be_present
    expect(ach_file.uuid).to be_a(String)
  end

  it "uses uuid for to_param" do
    ach_file = described_class.create!(user:)
    expect(ach_file.to_param).to eq(ach_file.uuid)
  end

  it "belongs to a user" do
    assoc = described_class.reflect_on_association(:user)
    expect(assoc.macro).to eq :belongs_to
  end

  it "defines the status enum" do
    expect(described_class.statuses).to eq("parsing" => 0, "completed" => 1, "failed" => 2)
  end

  it "defines the storage_type enum" do
    expect(described_class.storage_types).to eq("temporary" => 0, "permanent" => 1)
  end
end
