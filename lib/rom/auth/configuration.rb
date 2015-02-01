module ROM
  module Auth
    class Configuration
      include Virtus.model

      attribute :users_table_name, Symbol, default: :users
      attribute :email_confirmation_token_length, Range
      attribute :cookie_authentication_token_length, Range
      #attribute :authentication_credentials_table_name, Symbol, default: ->(c,_){ c.prefixed_table_name('authentication_credentials') }
      #attribute :authentication_events_table_name, Symbol, default: ->(c,_){ c.prefixed_table_name('authentication_events') }
      attribute :instrumentation, Object, default: ->(c,_){ c.find_default_instrumentation }
      attribute :plugins, Hash, default: {}

      def plugin(name, options={}, &block)
        self.plugins = plugins.merge(name => [options, block])
      end

      def prefixed_table_name(name)
        [singular_users_table_name,name].join('_').to_sym
      end

      def singular_users_table_name
        users_table_name.to_s.singularize
      end

      def find_default_instrumentation
        ActiveSupport::Notifications
      end
    end
  end
end
