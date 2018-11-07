# frozen_string_literal: true

module ApiAuth
  module Client
    class Response
      attr_reader :response, :parsed, :attrs

      # @param response [RestClient::Response]
      def initialize(response)
        @response = response
        parse
      end

      def [](arg)
        parsed.send(arg)
      end

      def to_json
        JSON.parse(response.body)
      end

      def method_missing(meth, *args, &blk)
        return response.send(meth, *args, &blk) if response.respond_to?(meth)
        return parsed.send(meth) if parsed.respond_to?(meth)

        super
      end

      def respond_to_missing?(meth, include_private = false)
        response.respond_to?(meth) || parsed.respond_to?(meth) || super
      end

    private

      def parse
        @parsed = JSON.parse(response, object_class: OpenStruct)
      rescue JSON::ParserError
        @parsed = nil
      end
    end
  end
end
