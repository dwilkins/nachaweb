require 'rails_helper'
require 'nacha'

RSpec.describe "Api::V1::Parse", type: :request do
  describe "POST /api/v1/parse/record" do
    context "with a valid record" do
      let(:user) { User.create!(email_address: "test-user@example.com", password: "password") }

      before do
        post session_path, params: { user: { email_address: user.email_address, password: "password" } }
      end

      it "returns a successful response" do
        record_string = File.readlines("spec/fixtures/files/valid_ach_file.txt").first
        post "/api/v1/parse/record", params: record_string, headers: { "CONTENT_TYPE" => "text/plain" }
        expect(response).to have_http_status(:success)
      end
    end

    context "with an invalid record" do
      it "returns an unprocessable entity response" do
        post "/api/v1/parse/record", params: "invalid_record", headers: { "CONTENT_TYPE" => "text/plain" }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "POST /api/v1/parse/file" do
    context "with a valid file" do
      it "returns a successful response" do
        file_string = File.read("spec/fixtures/files/valid_ach_file.txt")
        post "/api/v1/parse/file", params: file_string, headers: { "CONTENT_TYPE" => "text/plain" }
        expect(response).to have_http_status(:success)
      end
    end

    context "with an invalid file" do
      it "returns an unprocessable entity response" do
        post "/api/v1/parse/file", params: "invalid_file", headers: { "CONTENT_TYPE" => "text/plain" }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
