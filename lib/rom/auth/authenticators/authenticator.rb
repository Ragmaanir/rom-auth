module ROM::Auth
  module Authenticators
    class Authenticator
      include Support::ShorthandSymbol.strip(/Authenticator/)

      def authenticate(*args)
        raise NotImplementedError
      end
    end
  end
end
