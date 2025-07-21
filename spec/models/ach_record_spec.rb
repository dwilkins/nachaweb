require 'rails_helper'

RSpec.describe AchRecord, type: :model do
  describe 'associations' do
    it { should belong_to(:ach_file) }
  end
end