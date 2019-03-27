require "spec_helper"

describe Subvalid::Validators::LengthValidator do
  Thing = Struct.new(:list)
  let(:thing) { Thing.new(list) }
  let(:list) { [] }

  describe '#validate' do
    context 'when attribute is a string' do
      context 'with minimum' do
        class MinValidator
          include Subvalid::Validator
          validates :list, length: {minimum: 2}
        end

        subject(:validator) { MinValidator.validate(thing) }

        it 'returns a validation result' do
          expect(validator).to be_a(Subvalid::ValidationResult)
        end

        context 'when the length is just right' do
          let(:list) { 'a' * 3 }
          it { is_expected.to be_valid }
        end

        context 'when the length is too short' do
          it { is_expected.not_to be_valid }

          it 'shows the default error message' do
            expect(validator.children[:list].errors).to include("cannot be shorter than 2 characters")
          end
        end
      end

      context 'with maximum' do
        class MaxValidator
          include Subvalid::Validator
          validates :list, length: {maximum: 10}
        end

        subject(:validator) { MaxValidator.validate(thing) }

        it 'returns a validation result' do
          expect(validator).to be_a(Subvalid::ValidationResult)
        end

        context 'when the length is just right' do
          it { is_expected.to be_valid }
        end

        context 'when the length is too long' do
          let(:list) { 'a' * 30 }
          it { is_expected.not_to be_valid }

          it 'shows the default error message' do
            expect(validator.children[:list].errors).to include("cannot be longer than 10 characters")
          end
        end
      end

      context 'with exact character count' do
        class ExactLengthValidator
          include Subvalid::Validator
          validates :list, length: {is: 4}
        end

        subject(:validator) { ExactLengthValidator.validate(thing) }

        it 'returns a validation result' do
          expect(validator).to be_a(Subvalid::ValidationResult)
        end

        context 'when the length is just right' do
          let(:list) { 'a' * 4 }
          it { is_expected.to be_valid }
        end

        context 'when the length is too short' do
          it { is_expected.not_to be_valid }
        end

        context 'when the length is too long' do
          let(:list) { 'a' * 5 }
          it { is_expected.not_to be_valid }

          it 'shows the default error message' do
            expect(validator.children[:list].errors).to include("should have exactly 4 characters")
          end
        end
      end

      context 'with a range' do
        context 'when using within' do
          class WithinValidator
            include Subvalid::Validator
            validates :list, length: {within: 2..4}
          end

          subject(:validator) { WithinValidator.validate(thing) }

          it 'returns a validation result' do
            expect(validator).to be_a(Subvalid::ValidationResult)
          end

          context 'when the length is just right' do
            let(:list) { 'a' * 3 }
            it { is_expected.to be_valid }
          end

          context 'when the length is too short' do
            it { is_expected.not_to be_valid }
          end

          context 'when the length is too long' do
            let(:list) { 'a' * 5 }
            it { is_expected.not_to be_valid }

            it 'shows the default error message' do
              expect(validator.children[:list].errors).to include("should contain 2 to 4 characters")
            end
          end
        end

        context 'when using in' do
          class InValidator
            include Subvalid::Validator
            validates :list, length: {in: 2..4}
          end

          subject(:validator) { InValidator.validate(thing) }

          it 'returns a validation result' do
            expect(validator).to be_a(Subvalid::ValidationResult)
          end

          context 'when the length is just right' do
            let(:list) { 'a' * 3 }
            it { is_expected.to be_valid }
          end

          context 'when the length is too short' do
            it { is_expected.not_to be_valid }
          end

          context 'when the length is too long' do
            let(:list) { 'a' * 5 }
            it { is_expected.not_to be_valid }

            it 'shows the default error message' do
              expect(validator.children[:list].errors).to include("should contain 2 to 4 characters")
            end
          end
        end
      end
    end

    context 'when attribute is an array' do
      context 'with custom message' do
        class MaxWithMessageValidator
          include Subvalid::Validator
          validates :list, length: {maximum: 4, message: "cannot contain more than 5 items"}
        end

        subject(:validator) { MaxWithMessageValidator.validate(thing) }

        context 'when there are too many elements' do
          context 'with provided message' do
            let(:list) { [:a] * 5 }

            it 'shows custom error message' do
              expect(validator.children[:list].errors).to include("cannot contain more than 5 items")
            end
          end
        end
      end
    end
  end
end
