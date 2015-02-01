# DEPRECATED
module ROM
  module Auth
    module Migrations
      class UserTableMigration

        attr_reader :database, :config

        def initialize(config, database)
          @database = database
          @config = config
        end

        def column_exists?(table, column)
          database.schema(table).find{ |col| col.first == column }
        end

        def run
          me = self
          config = self.config

          database.create_table?(config.users_table_name) do
            primary_key :id
          end

          database.alter_table(config.users_table_name) do
            if !me.column_exists?(config.users_table_name, :email)
              add_column :email, String, null: false, unique: true
            end
          end

          database.create_table(config.login_credentials_table_name) do
            foreign_key(config.singular_users_table_name.to_sym, config.users_table_name.to_sym)

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

          database.create_table(config.login_events_table_name) do
            primary_key :id
            foreign_key(config.singular_users_table_name.to_sym, config.users_table_name.to_sym)
            Boolean   :success
            DateTime  :created_at
            String    :authentication_method
            String    :data
            # TODO login_ip
          end
        end
      end
    end
  end
end
