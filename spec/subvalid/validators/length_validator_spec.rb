require "spec_helper"

describe Subvalid::Validators::LengthValidator do
  Thing = Struct.new(:list)
  class ThingValidator
    include Subvalid::Validator
    validates :list, length: {minimum: 2, maximum: 4}
  end

  let(:thing) { Thing.new(list) }
  let(:list) { [] }

  describe '#validate' do
    subject(:validator) { ThingValidator.validate(thing) }

    it 'returns a validation result' do
      expect(validator).to be_a(Subvalid::ValidationResult)
    end

    context 'when the length is just right' do
      let(:list) { [:a] * 3 }
      it { is_expected.to be_valid }
    end

    context 'when the length is too short' do
      it { is_expected.not_to be_valid }
    end

    context 'when the length is too long' do
      let(:list) { [:a] * 5 }
      it { is_expected.not_to be_valid }
    end
  end
end
