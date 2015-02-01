module ROM::Auth
  module Plugins
    module AuthenticationEvents
      class AuthenticationEventsMigration < Migrations::Migration
        def run
          config = self.config
          fk_name = (config.singular_users_table_name+'_id').to_sym

          database.create_table(config.table_name) do
            primary_key :id
            foreign_key(fk_name, config.users_table_name.to_sym)
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
    end
  end
end
