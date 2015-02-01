module ROM::Auth
  module Services
    class AuthenticationService

      def initialize(auth)
        @auth = auth
        @now = Time.now
      end

      def authenticate(*args)
        raise NotImplementedError
      end

      def authentication_method
        raise NotImplementedError
      end

    protected

      def now
        @now
      end

      def log_login_attempt(user, verified)
        # FIXME type checking
        #assert_type(user, User)

        if verified
          if user.can_login?
            log_successful_attempt(user)
          else
            log_failed_attempt(user, :cannot_login)
          end
        else
          log_failed_attempt(user, :failed_verification)
        end
      end

      def log_successful_attempt(user)
        log_event(user, :success, {})
      end

      def log_failed_attempt(user, type)
        raise ArgumentError unless type.in?([:cannot_login, :failed_verification])

        log_event(user, :failure, data: { reason: type })

        # TODO
        # - log origin/details & warn user
        # - compute failed logins per minute and alert if above threshold
        # - throttling
        #
      end

      def log_event(user, result, data)
        meth = authentication_method
        now = @now
        ROM.env.command(@auth.configuration.login_events_table_name).try{
          create(
            success: (result!=:failure),
            created_at: now,
            authentication_method: meth.to_s,
            data: data.to_s
          )
        }

        ActiveSupport::Notifications.instrument('events:security:authentication_attempt',
          user_id: user.id,
          authentication_method: authentication_method,
          result: result,
          data: data
        )
      end

      def info(&block)
        security_logger.info(&block)
      end

      def assert_type(value, type)
        raise ArgumentError, "Expected #{type}, got #{value.class}" if value.class != type
      end
    end
  end
end
