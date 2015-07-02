module Subvalid
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
end
