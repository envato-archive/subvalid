module Subvalid
  module Validators
    class LengthValidator
      def self.validate(object, validation_result=ValidationResult.new, *args)
        return unless object
        args = args.to_h
        args.each do |operator, value|
          case operator
          when :maximum
            validation_result.add_error("is too long, maximum is #{value}") if object.size >= value
            # TODO ALL the other operators from http://guides.rubyonrails.org/active_record_validations.html#length
          else
            raise "don't know what to do with operator=#{operator}"
          end
        end
      end
    end
    ValidatorRegistry.register(:length, LengthValidator)
  end
end
