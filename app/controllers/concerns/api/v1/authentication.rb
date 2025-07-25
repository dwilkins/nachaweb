module Api
  module V1
    module Authentication
      extend ActiveSupport::Concern

      included do
        before_action :authenticate_with_api_key
      end

      private

      def authenticate_with_api_key
        api_key = request.headers["Authorization"].to_s.remove("Bearer ")
        @current_api_key = ApiKey.find_by(token: api_key)

        unless @current_api_key&.active?
          render json: { error: "Invalid API key" }, status: :unauthorized
        end
      end

      def current_user
        @current_api_key&.user
      end
    end
  end
end
