module Subvalid
  class ValidationResult
    attr_reader :errors, :children

    def initialize
      @errors = []
      @children = {}
    end

    def valid?
      errors.empty? && children.values.all?(&:valid?)
    end

    def add_error(error)
      errors << error
    end

    def [](attribute)
      children[attribute]
    end

    def merge_child!(attribute, result)
      child = children[attribute]
      if child
        child.merge!(result)
      else
        children[attribute] = result
      end
    end

    def to_h
      hash = {}
      hash[:errors] = errors.dup unless errors.empty?
      children.each do |attribute, child|
        hash[attribute] = child.to_h unless child.valid?
      end
      hash
    end

    def flatten(parent_attributes=[])
      # TODO make this more flexible than just hardcoded format
      flat_errors = errors.map{|error|
        if parent_attributes.empty?
          error
        else
          human_keys = parent_attributes.map{|a| a.to_s.gsub('_', ' ')}
          [human_keys.join(", "), error].join(": ")
        end
      }
      children.each do |attribute, child|
        flat_errors += child.flatten(parent_attributes + [attribute])
      end
      flat_errors
    end

    protected
    def merge!(result)
      @errors += result.errors
      children.merge!(result.children){|key, old_child, new_child|
        old_child.merge!(new_child)
        old_child
      }
    end
  end
end
