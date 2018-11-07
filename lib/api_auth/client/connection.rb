# frozen_string_literal: true

require 'rest-client'
require 'api-auth'

module ApiAuth
  module Client
    class Connection
      attr_reader :url, :app_id, :secret_key

      def initialize(url, app_id: nil, secret_key: nil)
        @url = url
        @app_id = app_id
        @secret_key = secret_key
      end

      def get(path, payload = {})
        query :get, path, payload
      end

      def post(path, payload = {})
        query :post, path, payload
      end

      def put(path, payload = {})
        query :put, path, payload
      end

      def delete(path, payload = {})
        query :delete, path, payload
      end

      def query(mtd, path, payload = {}) # rubocop:disable Metrics/AbcSize
        req = build_request(mtd, path, payload)
        response = execute(req)
        Response.new(response)
      rescue RestClient::RequestTimeout, RestClient::Exceptions::OpenTimeout
        raise ConnectionError.new('Error', { errors: ['Connection timeout'] }, 400)
      rescue Errno::ECONNREFUSED => e
        raise ConnectionError.new('Connection Error', { message: e.message }, 400)
      rescue RestClient::ExceptionWithResponse => e
        response = Response.new(e.response)
        raise ApiEndpointError.new(response[:errors] || e.message, response, response.code)
      end

    private

      def build_request(mtd, path, payload)
        RestClient::Request.new(
          method: mtd,
          url: endpoint_uri(path),
          payload: payload.to_json,
          ssl_version: 'SSLv23',
          headers: {
            content_type: :json,
            accept: :json,
          },
        )
      end

      def execute(req)
        return req.execute if app_id.nil? || app_id.empty?

        ::ApiAuth.sign!(req, app_id, secret_key, with_http_method: true).execute
      end

      def endpoint_uri(path = '')
        "#{url}/#{path.gsub(%r{^\/}, '')}"
      end
    end
  end
end
