require 'rails_helper'

RSpec.describe "ApiKeys", type: :request do
  context "when not authenticated" do
    it "redirects GET /api_keys to login" do
      get api_keys_path
      expect(response).to redirect_to(new_session_path)
    end

    it "redirects POST /api_keys to login" do
      post api_keys_path, params: { api_key: { description: "foo" } }
      expect(response).to redirect_to(new_session_path)
    end

    it "redirects GET /api_keys/new to login" do
      get new_api_key_path
      expect(response).to redirect_to(new_session_path)
    end
  end

  context "when authenticated" do
    let(:user) { User.create!(email_address: "test-user@example.com", password: "password") }

    before do
      post session_path, params: { user: { email_address: user.email_address, password: "password" } }
    end

    describe "GET /index" do
      it "returns a successful response" do
        get api_keys_path
        expect(response).to be_successful
      end
    end

    describe "GET /new" do
      it "returns a successful response" do
        get new_api_key_path
        expect(response).to be_successful
      end
    end

    describe "POST /create" do
      context "with valid parameters" do
        let(:valid_attributes) { { description: "My Test Key" } }

        it "creates a new ApiKey" do
          expect do
            post api_keys_path, params: { api_key: valid_attributes }
          end.to change(ApiKey, :count).by(1)
        end

        it "redirects to the api keys index" do
          post api_keys_path, params: { api_key: valid_attributes }
          expect(response).to redirect_to(api_keys_path)
          expect(flash[:notice]).to be_present
          expect(flash[:token]).to be_present
        end
      end

      context "with invalid parameters" do
        let(:invalid_attributes) { { description: "" } }

        it "does not create a new ApiKey" do
          expect do
            post api_keys_path, params: { api_key: invalid_attributes }
          end.not_to change(ApiKey, :count)
        end

        it "renders the 'new' template with unprocessable_entity status" do
          post api_keys_path, params: { api_key: invalid_attributes }
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response).to render_template(:new)
        end
      end
    end

    describe "DELETE /destroy" do
      let!(:api_key) { user.api_keys.create!(description: "Key to be deleted") }

      it "destroys the requested api_key" do
        expect do
          delete api_key_path(api_key)
        end.to change(ApiKey, :count).by(-1)
      end

      it "redirects to the api_keys list" do
        delete api_key_path(api_key)
        expect(response).to redirect_to(api_keys_path)
        expect(flash[:notice]).to eq("API Key was successfully revoked.")
      end

      it "does not allow deleting another user's key" do
        another_user = User.create!(email_address: "another@example.com", password: "password")
        another_key = another_user.api_keys.create!(description: "Another key")
        expect do
          delete api_key_path(another_key)
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
