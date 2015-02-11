module ROM::Auth
  module Plugins
    class LockdownPlugin < Plugin

      class Configuration
        include Virtus.model

        attribute :table_name, Symbol, default: nil
        attribute :lock_strategy, Object
        attribute :unlock_strategy, Object
      end

      def initialize(*args)
        super

        # FIXME move to configuration?
        configuration.table_name ||= system.configuration.users_table_name
      end

      def install
        system.extend(CallbackOverrides)

        config = configuration

        @relation = Class.new(ROM::Relation[:sql]) do
          register_as :rom_auth_lockdowns
          dataset(config.table_name)

          def by_user_id(user_id)
            where(id: user_id)
          end
        end

        @mapper = Class.new(ROM::Mapper) do
          relation(:rom_auth_lockdowns)
          model(Lockdown)
        end

        @command = Class.new(ROM::Commands::Update[:sql]) do
          register_as :update
          relation(:rom_auth_lockdowns)
          result :one
        end
      end

      def migrate(setup)
        LockdownMigration.new(system, setup, configuration).run
      end

      def lock_strategy
        configuration.lock_strategy
      end

      def unlock_strategy
        configuration.unlock_strategy
      end

      def is_locked?(user_id)
        #user.locked_at.present?
        ROM.env.read(:rom_auth_lockdowns).by_user_id(user_id).first.try(:locked_at).present?
      end

      def lock(user_id, reason)
        ROM.env.command(:rom_auth_lockdowns).update.where(id: user_id).call(locked_at: Time.now, lock_reason: reason)
      end

      def unlock(user_id)
        ROM.env.command(:rom_auth_lockdowns).update.where(id: user_id).set(locked_at: nil, lock_reason: nil)
      end

      class LockdownMigration < Migration
        def run
          config = self.config
          auth_config = system.configuration

          database.alter_table(config.table_name) do
            add_column :locked_at, DateTime, default: nil, null: true
            add_column :lock_reason, String, null: true
          end
        end
      end

      class Lockdown
        include Virtus.value_object(coerce: false)

        values do
          attribute :id, Integer
          attribute :locked_at, DateTime
          attribute :lock_reason, String
        end
      end

      module CallbackOverrides
        def authentication_authorized?(user, credentials)
          plugin = plugins[LockdownPlugin]

          plugin.unlock_strategy.call(plugin, user, credentials) if plugin.lock_strategy
          super && !plugin.is_locked?(user.id)
        end

        def on_authentication_completed(data)
          super

          plugin = plugins[LockdownPlugin]

          plugin.lock_strategy.call(plugin, data[:user_id], data) if plugin.lock_strategy
        end
      end

    end
  end
end
