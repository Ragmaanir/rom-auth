module ROM::Auth
  module Plugins
    class LockdownPlugin < Plugin

      class Configuration
        include Virtus.model

        attribute :table_name, Symbol, default: nil
        attribute :lock_strategy, Class
        attribute :unlock_strategy, Class
      end

      attr_reader :lock_strategy, :unlock_strategy

      def initialize(*args)
        super

        # FIXME move to configuration?
        configuration.table_name ||= system.user_table_name
      end

      def install
        config = configuration

        @mapper = Class.new(ROM::Mapper) do
          relation(config.table_name)
          model(LockdownModel)
        end

        @relation = Class.new(ROM::Relation[:sql]) do
          base_name(config.table_name)
        end
      end

      def migrate(setup)
        AuthenticationCredentialsMigration.new(system, setup, configuration).run
      end

      class LockdownMigration < Migration
        def run
          config = self.config
          auth_config = system.configuration

          database.alter_table(config.table_name) do
            add_column :locked_at, DateTime, default: nil, null: true
            add_column :lock_reason, String, null: false
          end
        end
      end

      class LockdownModel
        include Virtus.value_object(coerce: false)

        values do
          attribute :locked_at, DateTime
        end
      end

      module CallbackOverrides
        def on_authentication_completed(data)
          super

          plugins[LockdownPlugin].lock_strategy.execute(self, data)
        end
      end

    end
  end
end
