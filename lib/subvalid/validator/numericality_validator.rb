require "subvalid/validator_registry"

module Subvalid
  module Validator
    class NumericalityValidator
      def self.validate(object, validation_result=ValidationResult.new, *args)
        args = args.to_h
        args.each do |operator, value|
          case operator
            when :greater_than_or_equal_to
              validation_result.add_error("must be greater than or equal to #{value}" ) unless object >= value
            # TODO ALL the other operators from http://guides.rubyonrails.org/active_record_validations.html#numericality
            else
              raise "don't know what to do with operator=#{operator}"
          end
        end
      end
    end
    ValidatorRegistry.register(:numericality, NumericalityValidator)
  end
end
