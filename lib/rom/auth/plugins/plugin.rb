module ROM::Auth
  module Plugins
    class Plugin
      include Support::ShorthandSymbol.strip(/Plugin/)

      attr_reader :system, :configuration

      def initialize(system, config)
        #raise ArgumentError unless system.kind_of?(AuthenticationSystem)
        @system = system
        #configure(&configurator)
        @configuration = config
      end

      # def configuration
      #   @configuration ||= self.class.const_get(:Configuration).new
      # end

      # def configure(&block)
      #   @configuration = nil
      #   block.call(configuration)
      # end

      def migrate(*args)
      end

      def install(*args)
        raise NotImplementedError
      end

    end
  end
end
