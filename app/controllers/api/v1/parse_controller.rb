require 'nacha'

module Api
  module V1
    class ParseController < ActionController::API
      def record
        raw_record = request.body.read
        records = Nacha.parse(raw_record)

        if records.any? && records.first.is_a?(Nacha::Record::Base)
          render json: record_to_h(records.first) # records[1] is the actual record
        else
          render json: { error: "Invalid ACH record" }, status: :unprocessable_entity
        end
      end

      def file
        raw_file = request.body.read
        records = Nacha.parse(raw_file)

        if records.any?
          render json: records.map { |r| record_to_h(r) }
        else
          render json: { error: "Invalid ACH file" }, status: :unprocessable_entity
        end
      end

      private

      def record_to_h(record)
        return {} if record.nil?

        if record.respond_to?(:to_h)
          record.to_h
        else
          {
            record_type: record.class.name.demodulize
          }
        end
      end
    end
  end
end
