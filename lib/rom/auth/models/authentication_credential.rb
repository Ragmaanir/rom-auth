module ROM
  module Auth
    module Models
      class AuthenticationCredential
        include Virtus.value_object(coerce: false)

        values do
          attribute :user_id, Integer # FIXME this could be dynamic and could be account_id
          attribute :created_at, DateTime
          attribute :updated_at, DateTime
          attribute :identifier, String
          attribute :type, String
          attribute :verifier_data, String
          attribute :verifier_type, String
        end

        def verifier
          PasswordVerifiers::PasswordVerifier.from_s(verifier_data)
        end
      end
    end
  end
end
