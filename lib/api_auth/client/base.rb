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
        attr_reader :attr_url, :attr_app_id, :attr_secret_key

        def connect(url:, app_id: nil, secret_key: nil)
          @attr_url = url
          @attr_app_id = app_id
          @attr_secret_key = secret_key
        end
      end

    private

      def connection
        @connection ||= Connection.new(
          url: self.class.attr_url,
          app_id: self.class.attr_app_id,
          secret_key: self.class.attr_secret_key,
        )
      end
    end
  end
end
