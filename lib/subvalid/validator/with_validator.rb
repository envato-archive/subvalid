require "subvalid/validator_registry"

module Subvalid
  module Validator
    class WithValidator
      def self.validate(object, validation_result=ValidationResult.new, *args)
        case args[0]
        when Class
          klass = args[0]
          klass.validate(object, validation_result)
        when Proc
          prok = args[0]
          prok.(object, validation_result)
        end
      end
    end
    ValidatorRegistry.register(:with, WithValidator)
  end
end
