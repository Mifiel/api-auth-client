# frozen_string_literal: true

require 'json'

module ApiAuth
  module Client
    class Response
      attr_reader :response, :parsed, :attrs

      # @param response [Hash | RestClient::Response]
      def initialize(response)
        fail ArgumentError, 'response is not a RestClient::Response' unless response.is_a?(RestClient::Response)

        @response ||= response
        parse
      end

      def [](arg)
        parsed.send(arg) if parsed.respond_to?(arg)
      end

      def to_json
        JSON.parse(response)
      rescue JSON::ParserError
        { 'error' => 'Bad JSON', 'body' => response.body }
      end

      def ok?
        response.code >= 200 && response.code < 400
      end

      def inspect
        parsed.inspect.gsub('OpenStruct', 'ApiAuth::Client::Response')
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
        @parsed ||= JSON.parse(response, object_class: OpenStruct)
      rescue JSON::ParserError
        @parsed = OpenStruct.new(error: 'Bad JSON', body: response.body)
      end
    end
  end
end
