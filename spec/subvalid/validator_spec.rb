require "spec_helper"

describe Subvalid::Validator do
  let(:stub_validator) {
    -> (object, result) { "testing #{object} " }
  }
  class FooValidator
    include Subvalid::Validator

    STUB_VALIDATOR = -> (object, result) { result.add_error("testing #{object}") }


    validates with: STUB_VALIDATOR
    validates :foo, with: STUB_VALIDATOR, if: -> (record) { record.some_predicate? }
    validates :child do
      validates :boz, with: STUB_VALIDATOR
    end
  end

  class TestValidator
    def self.validate(object, validation_result=ValidationResult.new, *args)
      validation_result.add_error("testing #{object}")
    end
  end
  Subvalid::ValidatorRegistry.register(:test, TestValidator)

  Poro = Struct.new(:foo, :bar, :child, :some_predicate) do
    def to_s
      "I'M A PORO"
    end

    def some_predicate?
      some_predicate
    end
  end

  PoroChild = Struct.new(:baz, :boz) do
    def to_s
      "I'M A PORO CHILD"
    end
  end

  let(:poro) {
    Poro.new(
      "foo",
      "bar",
      PoroChild.new("baz", "boz"),
      some_predicate
    )
  }

  let(:some_predicate) { true }

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

    context "when `if` modifier returns false" do
      let(:some_predicate) { false }
      it "doesn't execute validator" do
        expect(subject[:foo].errors).to eq([])
      end

      it "executes other validators" do
        expect(subject[:child][:boz].errors).to eq(["testing boz"])
      end
    end
  end

end
