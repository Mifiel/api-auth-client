# frozen_string_literal: true

module ApiAuth
  module Client
    class Base
      def self.inherited(child_class)
        child_class.class_eval do
          extend ClassMethods
        end
      end

      module ClassMethods
        attr_reader :attr_url, :attr_app_id, :attr_secret_key, :attr_type, :attr_auth_token, :attr_args

        def connect(url:, app_id: nil, secret_key: nil, type: :hmac, auth_token: nil, attr_args: {}) # rubocop:disable Metrics/ParameterLists
          @attr_url = url
          @attr_app_id = app_id
          @attr_secret_key = secret_key
          @attr_type = type&.to_sym
          @attr_auth_token = auth_token
          @attr_args = args
        end
      end

    private

      def connection
        @connection ||= Connection.new(
          url: self.class.attr_url,
          app_id: self.class.attr_app_id,
          secret_key: self.class.attr_secret_key,
          type: self.class.attr_type,
          auth_token: self.class.attr_auth_token,
          args: self.class.attr_args || {},
        )
      end
    end
  end
end
