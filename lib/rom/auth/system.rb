module ROM
  module Auth
    class System

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

      # def authenticators
      #   Authenticators::Authenticator.descendants.inject({}) do |acc, desc|
      #     acc.merge(desc.shorthand_symbol => desc)
      #   end
      # end

      def authenticate(credentials)
        raise ArgumentError unless credentials

        success = false
        now = Time.now
        user = identify_user(credentials)

        on_authentication_attempt(credentials)

        if user
          authenticated = run_authentication_check(credentials)

          if authenticated
            on_authentication_success(credentials)

            if authentication_authorized?(user, credentials)
              on_authorized_authentication(credentials)
              success = true
            else
              on_unauthorized_authentication(credentials)
            end
          else
            on_authentication_failure(credentials)
          end
        else
          on_identification_failure(credentials)
        end

        on_authentication_completed(
          identifier: credentials.identifier,
          user_id: (user[:id] if user),
          started_at: now,
          ended_at: Time.now,
          type: credentials.type,
          authenticated: authenticated,
          success: success
        )

        user if success
      end

      def logger
        configuration.logger
      end

      def inspect
        "#<ROM::Auth::AuthenticationSystem plugins: #{plugins.keys}>"
      end

    private

      def load_plugins!
        @plugins = configuration.plugins.inject({}) do |acc, (plugin, args)|
          acc.merge(plugin => plugin.new(self, *args))
        end

        @plugins.each do |_type, plugin|
          plugin.install
        end
      end

      def identify_user(credentials)
        raise NotImplementedError
      end

      def run_authentication_check(credentials)
        #authenticators[type].new.authenticate(user, data)
        raise NotImplementedError
      end

      def authentication_authorized?(user, credentials)
        true # FIXME
      end

      def on_authentication_attempt(credentials)
        configuration.logger.info("Attempt: #{credentials.identifier}")
      end

      def on_identification_failure(credentials)
        configuration.logger.info("Identification failed: #{credentials.identifier}")
      end

      def on_authentication_completed(data)
        raise ArgumentError unless data.is_a?(Hash)
        #raise ArgumentError unless data.keys.to_set == [:identifier, :user_id, :started_at, :ended_at, :authenticated, :authenticator, :success].to_set
        # TODO :reason ?

        instrument_authentication_event(data)

        # TODO
        # - log origin/details & warn user
        # - compute failed logins per minute and alert if above threshold
        # - throttling
        #
      end

      def on_authentication_failure(credentials)
        configuration.logger.info("Authentication failed: #{credentials.identifier}")
      end

      def on_authentication_success(credentials)
        configuration.logger.info("Authentication succeeded: #{credentials.identifier}")
      end

      def on_unauthorized_authentication(credentials)
        configuration.logger.info("Unauthorized: #{credentials.identifier}")
      end

      def on_authorized_authentication(credentials)
        configuration.logger.info("Authorized: #{credentials.identifier}")
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
