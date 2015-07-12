require "spec_helper"

describe Subvalid::ValidatorRegistry do
  describe "#[]" do
    before do
      described_class.register(:accessor_test, "a validator")
    end
    context "when validator with key is registered" do
      it "returns the validator" do
        expect(described_class[:accessor_test]).to eq("a validator")
      end
    end

    context "when validator doesn't exist" do
      it "raises an error" do
        expect { described_class[:bad_key] }.to raise_error
      end
    end
  end

  describe "#register" do
    it "add the validator with the key" do
      # yes, this is a duplicat of the #[] spec, but it demonstrates the publicly API, so we'll have it
      described_class.register(:register_test, "registered validator")
      expect(described_class[:register_test]).to eq("registered validator")
    end
  end
end
