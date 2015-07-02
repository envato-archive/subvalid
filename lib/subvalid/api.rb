module Subvalid
  module API
    def validate(object, validation_result=ValidationResult.new, *args)
      validations.each do |attribute, validators|
        attribute_result = if attribute == :base
                            validation_result
                          else
                            ValidationResult.new
                          end

        validators.each do |validator_entry|
          validator = ValidatorRegistry.validator(validator_entry.validator_key)
          if attribute == :base
            validator.validate(object, attribute_result, *validator_entry.args)
          elsif object
            validator.validate(object.send(attribute), attribute_result, *validator_entry.args)
          else
            # no-op if we 're asked to validate an attribute for a nil value - that needs to be caught by a user defined `presence` validation instead
          end
        end

        validation_result.merge_child(attribute, attribute_result) unless attribute == :base
      end
      validation_result
    end
  end
end
