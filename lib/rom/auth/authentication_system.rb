module ROM
  module Auth
    class AuthenticationSystem

      attr_reader :configuration, :plugins

      def initialize(config)
        raise ArgumentError unless config.is_a?(Configuration)
        @configuration = config

        load_plugins!
      end

      def migrate!(setup)
        plugins.each do |_type, plugin|
          plugin.migrate(setup)
        end
      end

      def authenticators
        Authenticators::Authenticator.descendants.inject({}) do |acc, desc|
          acc.merge(desc.shorthand_symbol => desc)
        end
      end

      def authenticate(type, user, data)
        now = Time.now

        on_authentication_attempt(type, user, data)

        authenticated = run_authentication_check(type, user, data)
        success = false

        if authenticated
          on_authentication_success(type, user, data)

          if authentication_authorized?(user, type: type)
            on_authorized_authentication(type, user, data)
            success = true
          else
            on_unauthorized_authentication(type, user, data)
          end
        else
          on_authentication_failure(type, user, data)
        end

        on_authentication_completed(
          user_id: user.id,
          started_at: now,
          ended_at: Time.now,
          authenticator: type.to_s,
          authenticated: authenticated,
          success: success
        )

        success
      end

    private

      def load_plugins!
        @plugins = configuration.plugins.inject({}) do |acc, (plugin, args)|
          acc.merge(plugin => plugin.new(self, *args))
        end

        @plugins.each do |_type, plugin|
          plugin.install(self)
        end
      end

      def run_authentication_check(type, user, data)
        authenticators[type].new.authenticate(user, data)
      end

      def authentication_authorized?(user, type: )
        true
      end

      def on_authentication_attempt(type, user, data)
      end

      def on_authentication_completed(data)
        raise ArgumentError unless data.is_a?(Hash)
        raise ArgumentError unless data.keys.to_set == [:user_id, :started_at, :ended_at, :authenticated, :authenticator, :success].to_set
        # TODO :reason ?

        instrument_authentication_event(data)

        # TODO
        # - log origin/details & warn user
        # - compute failed logins per minute and alert if above threshold
        # - throttling
        #
      end

      def on_authentication_failure(type, user, data)
      end

      def on_authentication_success(type, user, data)
      end

      def on_unauthorized_authentication(type, user, data)
      end

      def on_authorized_authentication(type, user, data)
      end

      def instrument_authentication_event(auth_data)
        configuration.instrumentation.instrument(
          'rom:auth:authentication_attempt',
          auth_data
        )
      end
    end
  end
end
