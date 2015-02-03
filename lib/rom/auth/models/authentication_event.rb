module ROM
  module Auth
    module Models
      class AuthenticationEvent
        include Virtus.value_object(coerce: false)

        values do
          attribute :user_id, Integer
          attribute :success, Boolean
          attribute :started_at, DateTime
          attribute :ended_at, DateTime
          attribute :authenticator, String
          attribute :authenticated, Boolean
          attribute :data, String
        end
      end
    end
  end
end
