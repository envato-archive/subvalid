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
        if validators.empty? && !block
          raise "no validations or block specified"
        end

        attributes = [:base] if attributes.empty?

        add_validations(attributes, validators, block)
      end

      private
      ValidatorEntry = Struct.new(:validator, :args)
      def validations
        @validations ||= Hash.new{|vals,attribute| vals[attribute] = [] }
      end

      def add_validations(attributes, validators, block)
        attributes.each do |attribute|
          validators.each do |validator_key, args|
            validator = ValidatorRegistry[validator_key]
            validations[attribute] << ValidatorEntry.new(validator, args)
          end
          validations[attribute] << ValidatorEntry.new(BlockValidator, block) if block
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
            validator = validator_entry.validator
            if attribute == :base
              validator.validate(object, attribute_result, *validator_entry.args)
            elsif object
              validator.validate(object.send(attribute), attribute_result, *validator_entry.args)
            else
              # no-op if we 're asked to validate an attribute for a nil value - that needs to be caught by a user defined `presence` validation instead
            end
          end

          validation_result.merge_child!(attribute, attribute_result) unless attribute == :base
        end
        validation_result
      end
    end

    class BlockValidator
      class Context
        include Subvalid::Validator::DSL
        include Subvalid::Validator::API
      end

      def self.validate(object, validation_result=ValidationResult.new, *args)
        #return unless object # don't pass nil object into block - this should be handled with a PresenceValidator if it needs to be flagged as a validation error
        block = args[0]

        context = Context.new
        context.instance_exec(&block)
        context.validate(object, validation_result, args)
      end
    end
  end
end
