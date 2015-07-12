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
