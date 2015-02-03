module ROM::Auth
  module Plugins
    class AuthenticationEventsPlugin < Plugin
      class Configuration
        include Virtus.model

        attribute :table_name, Symbol, default: :authentication_events
      end

      def install(system)
        system.extend(CallbackOverrides)

        config = configuration

        @mapper = Class.new(ROM::Mapper) do
          relation(config.table_name)
          model(Models::AuthenticationEvent)
        end

        @relation = Class.new(ROM::Relation[:sql]) do
          base_name(config.table_name)
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

      class AuthenticationEventsMigration < Migrations::Migration
        def run
          auth_config = system.configuration
          config = self.config
          fk_name = (auth_config.singular_users_table_name+'_id').to_sym

          database.create_table(config.table_name) do
            primary_key :id
            foreign_key(fk_name, auth_config.users_table_name.to_sym)
            DateTime  :started_at
            DateTime  :ended_at
            String    :authenticator
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

          ROM.env.command(plugins[AuthenticationEventsPlugin].configuration.table_name).try{
            create(data)
          }

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
