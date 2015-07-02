require "subvalid/validator/block_validator"
require "subvalid/validator/format_validator"
require "subvalid/validator/in_validator"
require "subvalid/validator/length_validator"
require "subvalid/validator/numericality_validator"
require "subvalid/validator/presence_validator"
require "subvalid/validator/with_validator"

module Subvalid
  module Validator
    def self.included(base)
      base.class_eval do
        extend DSL
      end
      base.extend API
    end
  end
end
