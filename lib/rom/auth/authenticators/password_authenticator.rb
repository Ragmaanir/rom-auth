module ROM::Auth
  module Authenticators
    class PasswordAuthenticator < Authenticator

      def authenticate(user, password)
        raise ArgumentError unless password.is_a?(String)

        user.password_verifier.verifies?(password)
      end

    end
  end
end
