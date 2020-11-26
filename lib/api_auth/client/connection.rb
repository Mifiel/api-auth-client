# frozen_string_literal: true

require 'rest-client'
require 'api-auth'

module ApiAuth
  module Client
    class Connection
      attr_reader :url, :app_id, :secret_key, :type, :auth_token, :args

      def initialize(url:, app_id: nil, secret_key: nil, type: nil, auth_token: nil, args: {}) # rubocop:disable Metrics/ParameterLists
        @url = url
        @app_id = app_id
        @secret_key = secret_key
        @type = type
        @auth_token = auth_token
        @args = args
      end

      %i[
        get
        post
        put
        delete
      ].each do |mtd|
        define_method("#{mtd}!") do |path = nil, payload = {}|
          query(mtd, path, payload)
        end

        define_method(mtd) do |path = nil, payload = {}|
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
        }.merge(args)

        params[:payload] = payload.to_json if payload.present?
        params.merge!(user: app_id, password: secret_key) if type == :basic
        RestClient::Request.new(params)
      end

      def json_headers
        headers = {
          content_type: :json,
          accept: :json,
        }
        headers.merge!(authorization: "Bearer #{auth_token}") if type == :token
        headers.merge!(args.delete(:headers)) if args.key?(:headers)
        headers
      end

      def execute(req)
        req = ::ApiAuth.sign!(req, app_id, secret_key, with_http_method: true).execute if type == :hmac
        req.execute
      end

      def endpoint_uri(path = '')
        return "#{url}/#{path.gsub(%r{^\/}, '')}" if path.present?

        url
      end
    end
  end
end
