module ROM
  module Auth
    module Models
      class AuthenticationCredential
        include Virtus.value_object(coerce: false)

        values do
          # TODO user foreign key
        end
      end
    end
  end
end
