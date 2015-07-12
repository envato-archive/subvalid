module Subvalid
  module Validator
    def self.included(base)
      base.class_eval do
        extend DSL
      end
      base.extend API
    end

    module DSL
      def validates(*attributes, **validators, &block)
        validators = validators.dup
        if block
          raise ":block is a reserved option" if validators[:block]
          validators[:block] = block
        end

        if validators.empty?
          raise "no validations or block specified"
        end

        attributes = [:base] if attributes.empty?

        add_validations(attributes, validators)
      end

      private
      ValidatorEntry = Struct.new(:validator_key, :args)
      def validations
        @validations ||= Hash.new{|vals,attribute| vals[attribute] = [] }
      end

      def add_validations(attributes, validators)
        attributes.each do |attribute|
          validators.each do |validator_key, args|
            validations[attribute] << ValidatorEntry.new(validator_key, args)
          end
        end
      end
    end

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
end
