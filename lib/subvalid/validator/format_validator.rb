require "subvalid/validator_registry"

module Subvalid
  module Validator
    class FormatValidator
      def self.validate(object, validation_result=ValidationResult.new, *args)
        options = args.to_h rescue args
        with = nil
        message = "is invalid"
        case options
        when Regexp
          with = options
        when Hash
          with = options.fetch(:with)
          message = options[:message] || message
        else
          raise "don't know what to do with #{options}"
        end
        validation_result.add_error(message) unless with.match(object)
      end
    end
    ValidatorRegistry.register(:format, FormatValidator)
  end
end
