module ROM
  module Auth
    class Configuration
      include Virtus.model

      attribute :users_table_name, Symbol, default: :users
      attribute :email_confirmation_token_length, Range
      attribute :cookie_authentication_token_length, Range
      attribute :instrumentation, Object, default: ->(c,_){ c.find_default_instrumentation }
      attribute :plugins, Hash, default: {}
      attribute :logger, Object, default: ->(_,_){
        Logger.new(STDOUT).tap do |l|
          l.level = Logger::WARN
          l.progname = 'ROM::Auth'
        end
      }

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

      def find_default_instrumentation
        ActiveSupport::Notifications
      end

      def singular_users_table_name
        users_table_name.to_s.singularize
      end

      def user_fk_name
        [singular_users_table_name, :id].join('_').to_sym
      end

    end
  end
end
