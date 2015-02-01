module ROM::Auth
  module Migrations
    class UsersMigration < Migration
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
      end
    end
  end
end
