# frozen_string_literal: true

require 'api_auth/client/base'
require 'api_auth/client/connection'
require 'api_auth/client/error_with_json'
require 'api_auth/client/response'
require 'api_auth/client/version'

module ApiAuth
  module Client
    class ConnectionError < ErrorWithJson; end
    class ApiEndpointError < ErrorWithJson; end
  end
end
