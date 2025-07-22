require 'rails_helper'

RSpec.describe "AchFiles", type: :request do
  include_context "authentication helpers"

  let(:user) { User.create!(email_address: "test-user@example.com", password: "password") }

  describe "GET /ach_files/new" do
    context "when logged in" do
      before do
        sign_in_as(user)
      end

      it "returns a successful response" do
        get new_ach_file_path
        expect(response).to have_http_status(:success)
      end
    end

    context "when logged out" do
      it "redirects to the login page" do
        get new_ach_file_path
        expect(response).to redirect_to(new_session_path)
      end
    end
  end

  describe "POST /ach_files" do
    context "when logged in" do
      before do
        sign_in_as(user)
      end

      context "with valid parameters" do
        context "when uploading a file" do
          it "creates a new AchFile and AchInputFile with correct attributes" do
            file_name = "test_ach.txt"
            file = fixture_file_upload(file_name, 'text/plain')
            ach_file_params = { ach_file: { file_data: file } }

            expect { post ach_files_path, params: ach_file_params }.to change(AchFile, :count).by(1)
            expect(response).to redirect_to(ach_file_path(AchFile.last))

            ach_file = AchFile.last
            ach_input_file = ach_file.ach_input_files.last

            expect(ach_input_file.modality).to eq("file_upload")
            expect(ach_input_file.source).to eq(file_name)
            expect(ach_input_file.name).to eq(file_name)
            expect(ach_input_file.file_data).to be_attached
          end
        end

        it "creates a new AchFile and redirects to the show page" do
          ach_file_params = { ach_file: { pasted_text: "some ach data" } }
          expect { post ach_files_path, params: ach_file_params }.to change(AchFile, :count).by(1)
          expect(response).to redirect_to(ach_file_path(AchFile.last))
        end
      end

      context "with invalid parameters" do
        it "does not create a new AchFile and re-renders the new template" do
          ach_file_params = { ach_file: { pasted_text: "" } }
          expect { post ach_files_path, params: ach_file_params }.not_to change(AchFile, :count)
          expect(response).to render_template(:new)
        end
      end
    end

    context "when logged out" do
      it "redirects to the login page" do
        ach_file_params = { ach_file: { pasted_text: "some ach data" } }
        post ach_files_path, params: ach_file_params
        expect(response).to redirect_to(new_session_path)
      end
    end
  end
end
