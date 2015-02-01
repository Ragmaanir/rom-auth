module ROM::Auth
  class Migrator
    def self.migrate!(*args)
      new.migrate!(*args)
    end

    def migrate!(config, setup)
      [
        Migrations::UsersMigration,
        Migrations::AuthenticationCredentialsMigration,
        Migrations::AuthenticationEventsMigration
      ].each do |migration|
        migration.new(config, setup.default.connection).run
      end
    end
  end
end
