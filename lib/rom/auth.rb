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

require 'rom/auth/migration'

require 'rom/auth/plugins/plugin'
require 'rom/auth/plugins/authentication_events_plugin'
require 'rom/auth/plugins/authentication_credentials_plugin'
require 'rom/auth/plugins/lockdown_plugin'

require 'rom/auth/password_verifiers/password_verifier'
require 'rom/auth/password_verifiers/pbkdf2_verifier'

module ROM
  module Auth

  end
end
