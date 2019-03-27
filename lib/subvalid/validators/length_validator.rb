module Subvalid
  module Validators
    class LengthValidator
      def self.validate(object, validation_result=ValidationResult.new, *args)
        return unless object
        args = args.to_h
        message = args.delete(:message)
        args.each do |operator, value|
          case operator
          when :minimum
            validation_result.add_error(message || "cannot be shorter than #{value} characters") if object.size < value
          when :maximum
            validation_result.add_error(message || "cannot be longer than #{value} characters") if object.size > value
          when :is
            validation_result.add_error(message || "should have exactly #{value} characters") if object.size != value
          when :in, :within
            validation_result.add_error(
              message || "should contain #{value.first} to #{value.last} characters"
            ) unless value.include? object.size
          else
            raise "don't know what to do with operator=#{operator}"
          end
        end
      end
    end
    ValidatorRegistry.register(:length, LengthValidator)
  end
end
