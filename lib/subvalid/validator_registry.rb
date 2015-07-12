module Subvalid
  class ValidatorRegistry
    class << self
      def [](key)
        validators[key] or raise "no validator with key=#{key}"
      end

      def register(key, validator)
        validators[key] = validator
      end

      private
      def validators
        @validators ||= {}
      end
    end
  end
end
