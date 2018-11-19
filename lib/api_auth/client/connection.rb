# frozen_string_literal: true

require 'rest-client'
require 'api-auth'

module ApiAuth
  module Client
    class Connection
      attr_reader :url, :app_id, :secret_key

      def initialize(url:, app_id: nil, secret_key: nil)
        @url = url
        @app_id = app_id
        @secret_key = secret_key
      end

      %i[
        get
        post
        put
        delete
      ].each do |mtd|
        define_method("#{mtd}!") do |path, payload = {}|
          query(mtd, path, payload)
        end

        define_method(mtd) do |path, payload = {}|
          begin
            send("#{mtd}!", path, payload)
          rescue ConnectionError, ApiEndpointError => e
            e.response
          end
        end
      end

      def query(mtd, path, payload = {}) # rubocop:disable Metrics/AbcSize
        req = build_request(mtd, path, payload)
        Response.new(execute(req))
      rescue RestClient::RequestTimeout, RestClient::Exceptions::OpenTimeout
        raise ConnectionError.new('Error', { errors: ['Connection timeout'] }, nil)
      rescue Errno::ECONNREFUSED, SocketError => e
        raise ConnectionError.new('Connection Error', { message: e.message }, nil)
      rescue RestClient::ExceptionWithResponse => e
        response = Response.new(e.response)
        msg = response[:errors] || e.message
        raise ApiEndpointError.new(msg, response, response.code)
      end

    private

      def build_request(mtd, path, payload)
        params = {
          method: mtd,
          url: endpoint_uri(path),
          ssl_version: 'SSLv23',
          headers: json_headers,
        }
        params[:payload] = payload.to_json if mtd == :post
        RestClient::Request.new(params)
      end

      def json_headers
        {
          content_type: :json,
          accept: :json,
        }
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
