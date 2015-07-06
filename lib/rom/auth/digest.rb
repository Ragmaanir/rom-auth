module ROM
  module Auth

    class Digest
      def initialize(data)
        raise(ArgumentError, "String required got #{data.class}") if !data.is_a?(String)
        @data = data
      end

      def length
        @data.length
      end

      def ==(other)
        raise ArgumentError if !other.is_a?(Digest)
        raise ArgumentError if length != other.length

        # SECURITY timing attack
        # TODO because of short-circuiting this is actually not 100% constant time. fix this.
        result = @data.chars.zip(other.to_s.chars).inject(true) do |res, (char, other_char)|
          eq = (char == other_char)
          res && eq
        end

        result
      end

      def to_s
        @data
      end
    end

  end
end
