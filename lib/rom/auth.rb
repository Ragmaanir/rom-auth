require 'bundler'
Bundler.setup

require 'rom'
require 'rom-sql'
require 'virtus'
require 'active_support'
require 'active_support/core_ext'

require 'rom/auth/support/shorthand_symbol'

require 'rom/auth/version'
require 'rom/auth/configuration'
require 'rom/auth/authentication_system'

require 'rom/auth/authenticators/authenticator'
require 'rom/auth/authenticators/password_authenticator'

require 'rom/auth/migrations/migration'

require 'rom/auth/plugins/plugin'
require 'rom/auth/plugins/authentication_events_plugin'
require 'rom/auth/plugins/authentication_credentials_plugin'

require 'rom/auth/models/user'
require 'rom/auth/models/authentication_credential'
require 'rom/auth/models/authentication_event'

require 'rom/auth/password_verifier'
require 'rom/auth/pbkdf2_verifier'

require 'rom/auth/services/authentication_service'
require 'rom/auth/services/password_authentication_service'

module ROM
  module Auth
    class << self

    #   def initialize
    #     configuration = self.configuration

    #     user_mapper = Class.new(ROM::Mapper) do
    #       relation(:users)
    #       model(Models::User)
    #     end

    #     user_relation = Class.new(ROM::Relation[:sql]) do
    #       base_name(configuration.users_table_name)
    #     end

    #     load_plugins!
    #     #install_plugins!
    #   end

    #   def load_plugins!
    #     @loaded_plugins = {}

    #     configuration.plugins.each do |cls, args|
    #       plugin = cls.new(self, *args)

    #       @loaded_plugins.merge!(cls.shorthand_symbol => plugin)
    #     end
    #   end

    #   # def install_plugins!
    #   #   @loaded_plugins.each do |_cls, plugin|
    #   #     plugin.install
    #   #   end
    #   # end

    #   def loaded_plugins
    #     @loaded_plugins
    #   end

    #   # def available_plugins
    #   #   Plugins::Plugin.descendants.inject({}) do |acc, desc|
    #   #     acc.merge(desc.shorthand_symbol => desc)
    #   #   end
    #   # end

    #   def configuration
    #     @configuration ||= Configuration.new
    #   end

    #   def configure
    #     @configuration = nil
    #     yield(configuration)
    #   end

    #   def migrate(setup)
    #     loaded_plugins.each do |_cls, plugin|
    #       plugin.migrate(setup)
    #     end
    #   end

    #   def authenticators
    #     Authenticators::Authenticator.descendants.inject({}) do |acc, desc|
    #       acc.merge(desc.shorthand_symbol => desc)
    #     end
    #   end

    #   def authenticate(type, user, data)
    #     # now = Time.now

    #     # on_authentication_attempt(type, user, data)

    #     # authenticated = run_authentication_check(type, user, data)
    #     # success = false

    #     # if authenticated
    #     #   on_authentication_success(type, user, data)

    #     #   if authentication_authorized?(user, type: type)
    #     #     on_authorized_authentication(type, user, data)
    #     #     success = true
    #     #   else
    #     #     on_unauthorized_authentication(type, user, data)
    #     #   end
    #     # else
    #     #   on_authentication_failure(type, user, data)
    #     # end

    #     # on_authentication_completed(
    #     #   user_id: user.id,
    #     #   started_at: now,
    #     #   ended_at: Time.now,
    #     #   authenticator: type.to_s,
    #     #   authenticated: authenticated,
    #     #   success: success
    #     # )

    #     # success
    #     AuthenticationService.new(loaded_plugins.map{|_name, plugin| plugin }).authenticate(type, user, data)
    #   end

    # private

    #   def run_authentication_check(type, user, data)
    #     authenticators[type].new.authenticate(user, data)
    #   end

    #   def authentication_authorized?(user, type: )
    #     true
    #   end

    #   def on_authentication_attempt(type, user, data)
    #   end

    #   def on_authentication_completed(data)
    #     raise ArgumentError unless data.is_a?(Hash)
    #     raise ArgumentError unless data.keys.to_set == [:user_id, :started_at, :ended_at, :authenticated, :authenticator, :success].to_set
    #     # TODO :reason ?

    #     # ROM.env.command(configuration.login_events_table_name).try{
    #     #   create(data)
    #     # }

    #     instrument_authentication_event(data)

    #     # TODO
    #     # - log origin/details & warn user
    #     # - compute failed logins per minute and alert if above threshold
    #     # - throttling
    #     #
    #   end

    #   def on_authentication_failure(type, user, data)
    #   end

    #   def on_authentication_success(type, user, data)
    #   end

    #   def on_unauthorized_authentication(type, user, data)
    #   end

    #   def on_authorized_authentication(type, user, data)
    #   end

    #   def instrument_authentication_event(auth_data)
    #     configuration.instrumentation.instrument(
    #       'rom:auth:authentication_attempt',
    #       auth_data
    #     )
    #   end

    end
  end
end
