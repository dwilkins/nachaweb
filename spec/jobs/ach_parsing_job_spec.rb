require 'rails_helper'

RSpec.describe AchParsingJob, type: :job do
  include ActiveJob::TestHelper

  let(:user) { User.create!(email_address: "test@example.com", password: "password") }
  let(:ach_file) { user.ach_files.create! }

  let(:valid_nacha_content) do
    "101 03130001202313801041908161055A094101Federal Reserve Bank   My Bank Name           12345678" +
      "5225Name on Account                     231380104 CCDVndr Pay        190816   1031300010000001" +
      "627231380104744-5678-99      0000500000location1234567Best Co. \#123456789012S 0031300010000001" +
      "627231380104744-5678-99      0000000125Fee123456789012Best Co. #123456789012S 0031300010000002" +
      "82250000020046276020000000500125000000000000231380104                          031300010000001" +
      "9000001000001000000020046276020000000500125000000000000                                       " +
      "9999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999" +
      "9999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999" +
      "9999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999" +
      "9999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999"
  end

  after do
    clear_enqueued_jobs
    clear_performed_jobs
  end

  describe "#perform" do
    context "when modality is file_upload" do
      let(:file_name) { "test_ach.txt" }
      let(:uploaded_file_io) { StringIO.new(valid_nacha_content) }

      before do
        ach_input_file = ach_file.ach_input_files.create!(
          modality: :file_upload,
          name: file_name,
          source: file_name
        )
        ach_input_file.file_data.attach(io: uploaded_file_io, filename: file_name, content_type: 'text/plain')
      end

      it "parses the file, updates ach_file status, and creates ach_records" do
        expect { AchParsingJob.perform_later(ach_file) }.to have_enqueued_job

        perform_enqueued_jobs

        ach_file.reload
        expect(ach_file.status).to eq("completed")
        expect(ach_file.ach_records.count).to be > 0
        expect(ach_file.error_message).to be_nil
      rescue RSpec::Expectations::ExpectationNotMetError => e
        puts "\nACH File Error: #{ach_file.error_message}" if ach_file.error_message.present?
        raise e
      end
    end

    context "when modality is pasted_text" do
      before do
        ach_file.ach_input_files.create!(
          modality: :pasted_text,
          source: valid_nacha_content
        )
      end

      it "parses the text, updates ach_file status, and creates ach_records" do
        perform_enqueued_jobs { AchParsingJob.perform_later(ach_file) }
        ach_file.reload
        expect(ach_file.status).to eq("completed")
        # expect(ach_file.parsed_data).not_to be_nil
        expect(ach_file.ach_records.count).to be > 0
        expect(ach_file.error_message).to be_nil
      rescue RSpec::Expectations::ExpectationNotMetError => e
        puts "\nACH File Error: #{ach_file.error_message}" if ach_file.error_message.present?
        raise e
      end
    end

    context "when modality is url" do
      let(:test_url) { "http://example.com/ach_file.txt" }

      before do
        ach_file.ach_input_files.create!(
          modality: :url,
          source: test_url
        )
        # Mock the web_fetch call within the job
        allow(URI).to receive(:open).and_return(StringIO.new(valid_nacha_content))
      end

      xit "parses the content from URL, updates ach_file status, and creates ach_records" do
        perform_enqueued_jobs { AchParsingJob.perform_later(ach_file) }

        ach_file.reload
        expect(ach_file.status).to eq("completed")
        expect(ach_file.parsed_data).not_to be_nil
        expect(ach_file.ach_records.count).to be > 0
        expect(ach_file.error_message).to be_nil
      rescue RSpec::Expectations::ExpectationNotMetError => e
        puts "\nACH File Error: #{ach_file.error_message}" if ach_file.error_message.present?
        raise e
      end
    end

    context "when parsing fails" do
      let(:invalid_content) { "invalid ach data" }

      before do
        ach_file.ach_input_files.create!(
          modality: :pasted_text,
          source: invalid_content
        )
      end

      xit "updates ach_file status to failed and sets error_message" do
        perform_enqueued_jobs { AchParsingJob.perform_later(ach_file) }

        ach_file.reload
        expect(ach_file.status).to eq("failed")
        expect(ach_file.parsed_data).to be_nil
        expect(ach_file.ach_records.count).to eq(0)
        expect(ach_file.error_message).not_to be_nil
      end
    end
  end
end
