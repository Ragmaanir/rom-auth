module ROM::Auth
  module Plugins
    class AuthenticationCredentialsPlugin < Plugin
      class Configuration
        include Virtus.model

        attribute :table_name, Symbol, default: :authentication_credentials
      end

      def install(system)
        config = configuration

        @mapper = Class.new(ROM::Mapper) do
          relation(config.table_name)
          model(Models::AuthenticationCredential)
        end

        @relation = Class.new(ROM::Relation[:sql]) do
          base_name(config.table_name)
        end
      end

      def migrate(setup)
        AuthenticationCredentialsMigration.new(system, setup, configuration).run
      end

      class AuthenticationCredentialsMigration < Migrations::Migration
        def run
          config = self.config
          auth_config = system.configuration

          database.create_table(config.table_name) do
            foreign_key(auth_config.singular_users_table_name.to_sym, auth_config.users_table_name.to_sym)

            String :password_verifier
            #add_constraint(:password_verifier_length, Sequel.function(:char_length, :password_verifier)=>64..255)

            DateTime :email_confirmed_at, null: true
            String :email_confirmation_token, null: true
            #add_constraint(:email_confirmation_token_length) { char_length(email_confirmation_token) == config.email_confirmation_token_length }
            #add_constraint(:email_confirmation_token_length, Sequel.function(:char_length, :email_confirmation_token) => config.email_confirmation_token_length)

            String :cookie_authentication_token, null: true
            #add_constraint(:cookie_authentication_token_length) { char_length(:cookie_authentication_token) == config.cookie_authentication_token_length }
            #add_constraint(:cookie_authentication_token_length, Sequel.function(:char_length, :cookie_authentication_token) => config.cookie_authentication_token_length)
          end
        end
      end

    end
  end
end
