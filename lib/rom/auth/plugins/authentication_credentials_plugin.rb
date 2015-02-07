module ROM::Auth
  module Plugins
    class AuthenticationCredentialsPlugin < Plugin

      class Configuration
        include Virtus.model

        attribute :table_name, Symbol, default: :authentication_credentials
      end

      def install
        system.extend(CallbackOverrides)

        config = configuration

        @mapper_cls = Class.new(ROM::Mapper) do
          relation(config.table_name)
          model(Models::AuthenticationCredential)
        end

        @relation_cls = Class.new(ROM::Relation[:sql]) do
          base_name(config.table_name)

          def find_record(credentials)
            where(
              type: credentials.type,
              identifier: credentials.identifier
            )
          end
        end
      end

      def migrate(setup)
        AuthenticationCredentialsMigration.new(system, setup, configuration).run
      end

      def find_credential_entry(credentials)
        ROM.env.read(configuration.table_name).find_record(credentials).first
      end

      def identify_user(credentials)
        cred = find_credential_entry(credentials)
        ROM.env.read(system.configuration.users_table_name).by_id(cred.user_id).first if cred
      end

      def authenticate(credentials)
        cred = find_credential_entry(credentials)

        cred.verifier.verifies?(credentials.password)
      end

      class AuthenticationCredentialsMigration < Migration
        def run
          config = self.config
          auth_config = system.configuration

          # database.create_table(config.table_name) do
          #   foreign_key(auth_config.singular_users_table_name.to_sym, auth_config.users_table_name.to_sym)

          #   String :password_verifier
          #   #add_constraint(:password_verifier_length, Sequel.function(:char_length, :password_verifier)=>64..255)

          #   DateTime :email_confirmed_at, null: true
          #   String :email_confirmation_token, null: true
          #   #add_constraint(:email_confirmation_token_length) { char_length(email_confirmation_token) == config.email_confirmation_token_length }
          #   #add_constraint(:email_confirmation_token_length, Sequel.function(:char_length, :email_confirmation_token) => config.email_confirmation_token_length)

          #   String :cookie_authentication_token, null: true
          #   #add_constraint(:cookie_authentication_token_length) { char_length(:cookie_authentication_token) == config.cookie_authentication_token_length }
          #   #add_constraint(:cookie_authentication_token_length, Sequel.function(:char_length, :cookie_authentication_token) => config.cookie_authentication_token_length)
          # end

          fk = (auth_config.singular_users_table_name+'_id').to_sym

          database.create_table(config.table_name) do
            foreign_key(fk, auth_config.users_table_name.to_sym)

            String :identifier
            String :type
            #add_constraint(:password_verifier_length, Sequel.function(:char_length, :password_verifier)=>64..255)

            String :verifier_data

            DateTime :confirmed_at, null: true
            String :confirmation_token, null: true
            #add_constraint(:email_confirmation_token_length) { char_length(email_confirmation_token) == config.email_confirmation_token_length }
            #add_constraint(:email_confirmation_token_length, Sequel.function(:char_length, :email_confirmation_token) => config.email_confirmation_token_length)

            #String :cookie_authentication_token, null: true
            #add_constraint(:cookie_authentication_token_length) { char_length(:cookie_authentication_token) == config.cookie_authentication_token_length }
            #add_constraint(:cookie_authentication_token_length, Sequel.function(:char_length, :cookie_authentication_token) => config.cookie_authentication_token_length)
          end
        end
      end

      module CallbackOverrides
        def identify_user(credentials)
          plugins[ROM::Auth::Plugins::AuthenticationCredentialsPlugin].identify_user(credentials)
        end

        def run_authentication_check(credentials)
          plugins[ROM::Auth::Plugins::AuthenticationCredentialsPlugin].authenticate(credentials)
        end
      end

    end
  end
end
