module ROM::Auth
  module Services
    class PasswordAuthenticationService < AuthenticationService

      def authentication_method
        :password
      end

      def authenticate(user, password)
        # FIXME type checking
        #assert_type(user, User)
        #assert_type(password, String)

        verified = user.password_verifier.verifies?(password)

        log_login_attempt(user, verified)

        verified && user.can_login?
      end

    end
  end
end
