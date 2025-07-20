require 'rails_helper'

RSpec.describe "Layout", type: :request do
  context "when not authenticated" do
    it "does not display the sidebar" do
      get root_path
      expect(response).to redirect_to(new_session_path)
      assert_select "aside", count: 0
    end
  end

  context "when authenticated" do
    let!(:user) { User.create!(email_address: "test-user@example.com", password: "password") }

    before do
      post session_path, params: { user: { email_address: user.email_address, password: "password" } }
    end

    it "displays the sidebar with navigation links on the root path" do
      get root_path
      expect(response).to be_successful
      assert_select "aside" do
        assert_select "nav a[href=?]", root_path, text: "Dashboard"
        assert_select "nav a[href=?]", api_keys_path, text: "API Keys"
      end
    end

    it "displays the sidebar on the api_keys path" do
      get api_keys_path
      expect(response).to be_successful
      assert_select "aside"
    end

    it "does not have an API Keys link in the main header" do
      get root_path
      assert_select "header a[href=?]", api_keys_path, count: 0
    end
  end
end
