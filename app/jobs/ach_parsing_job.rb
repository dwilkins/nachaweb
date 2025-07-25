require 'httparty'

class AchParsingJob < ApplicationJob
  queue_as :default

  def perform(ach_file)
    ach_file.parsing! # Set status to parsing

    begin
      ach_input_file = ach_file.ach_input_files.first
      content = case ach_input_file.modality.to_sym
                when :file_upload
                  ach_input_file.file_data.download
                when :pasted_text
                  ach_input_file.source
                when :url
                  response = HTTParty.get(ach_input_file.source)
                  raise "Failed to fetch URL: #{response.code}" unless response.success?
                  response.body
                else
                  raise "Unsupported modality: #{ach_input_file.modality}"
                end
      ach_records = Nacha.parse(content)

      ach_file.completed! # Set status to completed

      # Create AchRecord entries
      ach_records.each do |record|
        new_rec = ach_file.ach_records.create!(
          ach_record_name: record&.record_type || "Unknown",
          parsed_data: record.to_h
        )
      end

    rescue StandardError => e
      ach_file.error_message = e.message
      ach_file.failed! # Set status to failed
    end

    ach_file.save!
  end
end
