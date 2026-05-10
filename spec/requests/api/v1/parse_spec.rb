require 'rails_helper'
require 'nacha'

RSpec.describe "Api::V1::Parse", type: :request do
  describe "POST /api/v1/parse/record" do
    let(:user) { User.create!(email_address: "test-user@example.com", password: "password") }
    let(:api_key) { ApiKey.create!(user: user, description: "Test Key") }

    context "with a valid API key" do
      context "with a valid record" do
        it "returns a successful response" do
          record_string = File.readlines("spec/fixtures/files/valid_ach_file.txt").first
          post "/api/v1/parse/record", params: record_string, headers: { "CONTENT_TYPE" => "text/plain", "Authorization" => "Bearer #{api_key.token}" }
          expect(response).to have_http_status(:success)
        end
      end

      context "with an invalid record" do
        it "returns an unprocessable entity response" do
          post "/api/v1/parse/record", params: "invalid_record", headers: { "CONTENT_TYPE" => "text/plain", "Authorization" => "Bearer #{api_key.token}" }
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end

    context "without a valid API key" do
      it "returns an unauthorized response" do
        record_string = File.readlines("spec/fixtures/files/valid_ach_file.txt").first
        post "/api/v1/parse/record", params: record_string, headers: { "CONTENT_TYPE" => "text/plain" }
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "with a malformed Authorization header" do
      it "returns an unauthorized response" do
        record_string = File.readlines("spec/fixtures/files/valid_ach_file.txt").first
        post "/api/v1/parse/record", params: record_string, headers: { "CONTENT_TYPE" => "text/plain", "Authorization" => "InvalidToken" }
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "with an expired API key" do
      let(:expired_api_key) { ApiKey.create!(user: user, description: "Expired Key", expires_at: 1.day.ago) }

      it "returns an unauthorized response" do
        record_string = File.readlines("spec/fixtures/files/valid_ach_file.txt").first
        post "/api/v1/parse/record", params: record_string, headers: { "CONTENT_TYPE" => "text/plain", "Authorization" => "Bearer #{expired_api_key.token}" }
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "with a revoked API key" do
      let(:revoked_api_key) { ApiKey.create!(user: user, description: "Revoked Key", revoked_at: Time.current) }

      it "returns an unauthorized response" do
        record_string = File.readlines("spec/fixtures/files/valid_ach_file.txt").first
        post "/api/v1/parse/record", params: record_string, headers: { "CONTENT_TYPE" => "text/plain", "Authorization" => "Bearer #{revoked_api_key.token}" }
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "POST /api/v1/parse/file" do
    let(:user) { User.create!(email_address: "test-user@example.com", password: "password") }
    let(:api_key) { ApiKey.create!(user: user, description: "Test Key") }

    context "with a valid API key" do
      context "with a valid file" do
        it "returns a successful response" do
          file_string = File.read("spec/fixtures/files/valid_ach_file.txt")
          post "/api/v1/parse/file", params: file_string, headers: { "CONTENT_TYPE" => "text/plain", "Authorization" => "Bearer #{api_key.token}" }
          expect(response).to have_http_status(:success)
        end
      end

      context "with an invalid file" do
        it "returns an unprocessable entity response" do
          post "/api/v1/parse/file", params: "invalid_file", headers: { "CONTENT_TYPE" => "text/plain", "Authorization" => "Bearer #{api_key.token}" }
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end

    context "without a valid API key" do
      it "returns an unauthorized response" do
        file_string = File.read("spec/fixtures/files/valid_ach_file.txt")
        post "/api/v1/parse/file", params: file_string, headers: { "CONTENT_TYPE" => "text/plain" }
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "with a malformed Authorization header" do
      it "returns an unauthorized response" do
        file_string = File.read("spec/fixtures/files/valid_ach_file.txt")
        post "/api/v1/parse/file", params: file_string, headers: { "CONTENT_TYPE" => "text/plain", "Authorization" => "InvalidToken" }
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "with an expired API key" do
      let(:expired_api_key) { ApiKey.create!(user: user, description: "Expired Key", expires_at: 1.day.ago) }

      it "returns an unauthorized response" do
        file_string = File.read("spec/fixtures/files/valid_ach_file.txt")
        post "/api/v1/parse/file", params: file_string, headers: { "CONTENT_TYPE" => "text/plain", "Authorization" => "Bearer #{expired_api_key.token}" }
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "with a revoked API key" do
      let(:revoked_api_key) { ApiKey.create!(user: user, description: "Revoked Key", revoked_at: Time.current) }

      it "returns an unauthorized response" do
        file_string = File.read("spec/fixtures/files/valid_ach_file.txt")
        post "/api/v1/parse/file", params: file_string, headers: { "CONTENT_TYPE" => "text/plain", "Authorization" => "Bearer #{revoked_api_key.token}" }
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
