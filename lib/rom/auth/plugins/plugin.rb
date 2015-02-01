module ROM::Auth
  module Plugins
    class Plugin
      include Support::ShorthandSymbol.strip(/Plugin/)

      attr_reader :auth

      def initialize(auth, options={}, configurator)
        @auth = auth
        configure(&configurator)
      end

      def configuration
        @configuration ||= self.class.const_get(:Configuration).new
      end

      def configure(&block)
        @configuration = nil
        block.call(configuration)
      end

      def install
        raise NotImplementedError
      end
    end
  end
end
