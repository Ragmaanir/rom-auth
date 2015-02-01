module ROM::Auth
  module Migrations
    class Migration
      attr_reader :auth, :setup, :config

      def initialize(auth, setup, config)
        @auth = auth
        @setup = setup
        @config = config
      end

      def column_exists?(table, column)
        database.schema(table).find{ |col| col.first == column }
      end

      def run
        raise NotImplementedError
      end

    private

      def database
        @setup.default.connection
      end
    end
  end
end
