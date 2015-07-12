module Subvalid
  module Validators
    class InValidator
      def self.validate(object, validation_result=ValidationResult.new, *args)
        options = args.to_h rescue args
        within = nil
        message = "is not included in the list"
        case options
        when Hash
          within = options.fetch(:within)
          message = options[:message] || message
        when Array
          within = options
        else
          raise "don't know what to do with #{options}"
        end
        validation_result.add_error(message) unless within.include?(object)
      end
    end
    ValidatorRegistry.register(:in, InValidator)
  end
end
