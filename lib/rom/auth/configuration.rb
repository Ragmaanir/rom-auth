module ROM
  module Auth
    class Configuration
      include Virtus.model

      attribute :users_table_name, Symbol, default: :users
      attribute :email_confirmation_token_length, Range
      attribute :cookie_authentication_token_length, Range
      attribute :instrumentation, Object, default: ->(c,_){ c.find_default_instrumentation }
      attribute :plugins, Hash, default: {}
      attribute :logger, Object, default: Logger.new(STDOUT)

      def initialize(*args, &block)
        super(*args)
        block.call(self) if block
        self
      end

      def plugin(cls, options={}, &block)
        raise(ArgumentError, "Expected a class but was #{cls.inspect}") unless cls.is_a?(Class)
        config = cls.const_get(:Configuration).new(options)
        block.call(config) if block
        self.plugins = plugins.merge(cls => config)
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
