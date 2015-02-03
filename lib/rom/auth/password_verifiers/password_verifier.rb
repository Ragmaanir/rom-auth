module ROM
  module Auth
    module PasswordVerifiers
      class PasswordVerifier

        DEFAULT_OPTIONS       = { :iterations => 15000, :hash_function => :sha256 }.freeze
        DEFAULT_SALT_LENGTH   = 16
        SEPARATOR             = ","
        VERIFIERS             = {}

        attr_reader :salt, :digest, :options

        def verifies?(plaintext_password)
          # SECURITY timing attack
          self.digest == compute_digest(plaintext_password, salt, options)
        end

        def to_s
          [type, salt, digest, options[:iterations]].join(SEPARATOR)
        end

        def ==(other)
          case other
            when PasswordVerifier then to_s == other.to_s
            when String then to_s == other
            else false
          end
        end

        def self.for_password(plaintext_password, options={})
          raise ArgumentError unless plaintext_password.is_a?(String)
          new(options.merge(:password => plaintext_password))
        end

        def self.from_s(string)
          kind, salt, digest, iterations = string.split(SEPARATOR)

          VERIFIERS[kind.to_sym].new(DEFAULT_OPTIONS.merge(:digest => digest, :salt => salt, :iterations => iterations.to_i))
        end

      protected

        def initialize(options={})
          raise(ArgumentError, ":password or :digest required but got #{options.inspect}") unless options.values_at(:password, :digest).compact.one?

          @options  = DEFAULT_OPTIONS.merge(options)
          @salt     = @options.delete(:salt) || generate_random_salt(@options.delete(:salt_length))
          @digest   = @options.delete(:digest) || compute_digest(@options[:password], @salt, @options)
        end

        def compute_digest(plaintext_password, salt, options={})
          raise NotImplementedError
        end

        def generate_random_salt(length=nil)
          SecureRandom.hex(length || DEFAULT_SALT_LENGTH)
        end

      end
    end
  end
end
