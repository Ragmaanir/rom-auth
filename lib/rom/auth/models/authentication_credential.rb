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
          attribute :identifier_type, String
          attribute :verifier, String
          attribute :verifier_type, String
        end
      end
    end
  end
end
