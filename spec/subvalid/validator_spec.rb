require "spec_helper"

describe Subvalid::Validator do
  class FooValidator
    include Subvalid::Validator

    validates test: true
    validates :foo, test: true
    validates :child do
      validates :boz, test: true
    end
  end

  class TestValidator
    def self.validate(object, validation_result=ValidationResult.new, *args)
      validation_result.add_error("testing #{object}")
    end
  end
  Subvalid::ValidatorRegistry.register(:test, TestValidator)

  Poro = Struct.new(:foo, :bar, :child) do
    def to_s
      "I'M A PORO"
    end
  end

  PoroChild = Struct.new(:baz, :boz) do
    def to_s
      "I'M A PORO CHILD"
    end
  end

  let(:poro) { Poro.new("foo", "bar", 
                        PoroChild.new("baz", "boz")) }

  describe "#validate" do
    subject { FooValidator.validate(poro) }
    it "returns a validation result" do
      expect(subject).to be_a(Subvalid::ValidationResult)
    end

    it "validates base object" do
      expect(subject.errors).to eq(["testing I'M A PORO"])
    end

    it "validates attribute on object" do
      expect(subject[:foo].errors).to eq(["testing foo"])
    end

    it "validates child" do
      expect(subject[:child][:boz].errors).to eq(["testing boz"])
    end
  end

end
