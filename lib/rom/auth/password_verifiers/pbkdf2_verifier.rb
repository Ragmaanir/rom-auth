require 'pbkdf2'

module ROM
  module Auth
    module PasswordVerifiers
      class PBKDF2Verifier < PasswordVerifier

        PasswordVerifier::VERIFIERS.merge!(:PBKDF2 => PBKDF2Verifier)

        def type
          :PBKDF2
        end

      protected

        def compute_digest(plaintext_password, salt, options={})
          hex = PBKDF2.new(options.merge(:password => plaintext_password, :salt => salt)).hex_string
          Digest.new(hex)
        end

      end
    end
  end
end
