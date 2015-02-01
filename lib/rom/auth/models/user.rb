module ROM
  module Auth
    module Models
      class User
        include Virtus.value_object(coerce: false)

        values do
          attribute :email, String
          attribute :password_verifier, String
        end
      end
    end
  end
end
