module Subvalid
  module Validators
    class PresenceValidator
      def self.validate(object, validation_result=ValidationResult.new, *args)
        present = if object
                    if object.respond_to?(:present?)
                      object.present?
                    else
                      object
                    end
                  end

        validation_result.add_error("is not present") unless present
      end
    end
    ValidatorRegistry.register(:presence, PresenceValidator)
  end
end
