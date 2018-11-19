# frozen_string_literal: true

require_relative 'client/base'
require_relative 'client/connection'
require_relative 'client/error_with_json'
require_relative 'client/response'
require_relative 'client/version'

module ApiAuth
  module Client
    class ConnectionError < ErrorWithJson; end
    class ApiEndpointError < ErrorWithJson; end
  end
end
