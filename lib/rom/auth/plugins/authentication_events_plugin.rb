module ROM::Auth
  module Plugins
    class AuthenticationEventsPlugin < Plugin

      class Configuration
        include Virtus.model

        attribute :table_name, Symbol, default: :authentication_events
      end

      def install
        system.extend(CallbackOverrides)

        config = configuration

        @mapper = Class.new(ROM::Mapper) do
          relation(config.table_name)
          model(AuthenticationEvent)
          register_as :rom_auth_event
        end

        @relation = Class.new(ROM::Relation[:sql]) do
          dataset(config.table_name)
        end

        @command = Class.new(ROM::Commands::Create[:sql]) do
          register_as :create
          relation(config.table_name)
          result :one
        end
      end

      def migrate(setup)
        AuthenticationEventsMigration.new(system, setup, configuration).run
      end

      class AuthenticationEvent
        include Virtus.value_object(coerce: false)

        values do
          attribute :user_id, Integer # FIXME should be dynamic and could be account_id
          attribute :success, Boolean
          attribute :started_at, DateTime
          attribute :ended_at, DateTime
          attribute :identifier, String
          attribute :type, String
          attribute :authenticated, Boolean
          attribute :data, String
        end
      end

      class AuthenticationEventsMigration < Migration
        def run
          auth_config = system.configuration
          config = self.config
          user_fk_name = auth_config.user_fk_name

          database.create_table(config.table_name) do
            primary_key :id
            foreign_key(user_fk_name, auth_config.users_table_name.to_sym)
            DateTime  :started_at
            DateTime  :ended_at
            String    :identifier
            String    :type
            Boolean   :authenticated
            Boolean   :success
            String    :data
            # TODO login_ip, failure reason
          end
        end
      end

      module CallbackOverrides
        def on_authentication_completed(data)
          super

          # ROM.env.command(plugins[AuthenticationEventsPlugin].configuration.table_name).try{
          #   create(data)
          # }
          ROM.env.command(plugins[AuthenticationEventsPlugin].configuration.table_name).create.call(data)

          # TODO
          # - log origin/details & warn user
          # - compute failed logins per minute and alert if above threshold
          # - throttling
          #
        end
      end

    end
  end
end
