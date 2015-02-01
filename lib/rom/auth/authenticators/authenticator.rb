module ROM::Auth
  module Authenticators
    class Authenticator
      extend DescendantsTracker
      include Support::ShorthandSymbol.strip(/Authenticator/)

      def authenticate(*args)
        raise NotImplementedError
      end

      # def self.authenticator_name
      #   name.split('::').last.gsub(/Authenticator/,'').underscore.to_sym
      # end
    end
  end
end
