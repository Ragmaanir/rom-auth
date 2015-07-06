module ROM::Auth
  module Plugins
    class Plugin

      attr_reader :system, :configuration

      def initialize(system, config)
        raise ArgumentError unless system.kind_of?(System)
        @system = system
        @configuration = config
      end

      def migrate(*args)
      end

      def install(*args)
        raise NotImplementedError
      end

    end
  end
end
