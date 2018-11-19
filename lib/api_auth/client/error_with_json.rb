# frozen_string_literal: true

module ApiAuth
  module Client
    class ErrorWithJson < StandardError
      attr_accessor :response, :status, :json

      def initialize(message = nil, response = nil, status = nil)
        super(message)
        self.response = response
        self.status = status || (response.is_a?(RestClient::Response) && response.code)
        self.json = response.to_json
      end
    end
  end
end
