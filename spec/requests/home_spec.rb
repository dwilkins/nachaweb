require 'rails_helper'

RSpec.describe "Homes", type: :request do
  describe "GET /index" do
    let!(:user) { User.create!(email_address: "test-user@example.com", password: "password") }

    before do
      post session_path, params: { user: { email_address: user.email_address, password: "password" } }
    end

    it "returns http success" do
      get "/home/index"
      expect(response).to have_http_status(:success)
    end
  end

end
