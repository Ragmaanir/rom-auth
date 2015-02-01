module ROM::Auth
  module Support
    module ShorthandSymbol

      def self.strip(suffix)
        mod = Module.new

        mod.instance_eval <<-RUBY
          def included(cls)
            def cls.shorthand_symbol
              #name.split('::').last.gsub(/#{suffix.source}/,'').underscore.to_sym
              name.demodulize.gsub(/#{suffix.source}/,'').underscore.to_sym
            end
          end
        RUBY

        mod
      end

    end
  end
end
