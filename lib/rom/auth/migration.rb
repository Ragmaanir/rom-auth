module ROM::Auth
  class Migration
    attr_reader :system, :setup, :config

    def initialize(system, setup, config)
      @system = system
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
