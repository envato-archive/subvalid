require "spec_helper"

describe Subvalid::ValidationResult do
  describe "#valid?" do
    context "when there are no errors" do
      context "when children have no errors" do
        before do
          child = Subvalid::ValidationResult.new
          subject.children[:foo] = child
        end
        it { is_expected.to be_valid }
      end

      context "when children have errors" do
        before do
          child = Subvalid::ValidationResult.new
          child.add_error("this is an error")
          subject.children[:foo] = child
        end
        it { is_expected.to_not be_valid }
      end
    end

    context "when there are errors" do
      before do
        subject.add_error("this is an error")
      end
      it { is_expected.to_not be_valid }
    end
  end

  describe "#add_error" do
    it "adds the error" do
      subject.add_error("duh")
      subject.add_error("doh")
      expect(subject.errors).to eq(["duh", "doh"])
    end
  end

  describe "#[]" do
    context "when child attribute exists" do
      let(:child) { Subvalid::ValidationResult.new }
      before do
        subject.children[:foo] = child
      end
      it "returns the child validation result" do
        expect(subject[:foo]).to be(child)
      end
    end

    context "when child attribute does not exist" do
      it "returns nil" do
        expect(subject[:blah]).to be_nil
      end
    end
  end

  describe "merge_child!" do
    context "when child attribute already exists" do
      let(:child1) {
        result = Subvalid::ValidationResult.new
        result.add_error("Insufficient cheese")
        grandchild = Subvalid::ValidationResult.new
        grandchild.add_error("not tasty")
        result.merge_child!(:tastiness, grandchild)
        grandchild2 = Subvalid::ValidationResult.new
        grandchild2.add_error("it's not OK")
        result.merge_child!(:ok, grandchild2)
        result
      }
      let(:child2) {
        result = Subvalid::ValidationResult.new
        result.add_error("blue cheese is awful")
        grandchild = Subvalid::ValidationResult.new
        grandchild.add_error("more smelly than tasty")
        result.merge_child!(:tastiness, grandchild)
        result
      }
      it "merges results together recursively" do
        subject.merge_child!(:cheese, child1)
        subject.merge_child!(:cheese, child2)
        expect(subject[:cheese].errors).to eq(["Insufficient cheese", "blue cheese is awful"])
        expect(subject[:cheese][:tastiness].errors).to eq(["not tasty", "more smelly than tasty"])
        expect(subject[:cheese][:ok].errors).to eq(["it's not OK"])
      end
    end

    context "when child attribute doesn't exist" do
      let(:child) {
        result = Subvalid::ValidationResult.new
        result.add_error("Insufficient cheese")
        result
      }
      it "sets the child result from the passed in result" do
        subject.merge_child!(:cheese, child)
        expect(subject[:cheese].errors).to eq(["Insufficient cheese"])
      end
    end
  end

  describe "#to_h" do
    before do
      child = Subvalid::ValidationResult.new
      child.add_error("this is an error")
      grandchild1 = Subvalid::ValidationResult.new
      grandchild1.add_error("this is another error")
      grandchild2 = Subvalid::ValidationResult.new # no errors
      child.children[:bar] = grandchild1
      child.children[:baz] = grandchild2
      subject.children[:foo] = child
      subject.add_error("this is a base error")
    end

    it "generates a hash of attributes with errors" do
      expect(subject.to_h).to eq({
        errors: ["this is a base error"],
        foo: {
          errors: ["this is an error"],
          bar: {
            errors: ["this is another error"]
          }
        }
      })
    end

    it "has errors on attribute itself in special :errors key" do
      hash = subject.to_h
      expect(hash[:errors]).to eq(["this is a base error"])
      expect(hash[:foo][:errors]).to eq(["this is an error"])
      expect(hash[:foo][:bar][:errors]).to eq(["this is another error"])
    end

    it "doesn't include anything for attributes that are valid" do
      expect(subject.to_h[:foo]).to_not have_key(:baz)
    end
  end

  describe "#flatten" do
    before do
      child = Subvalid::ValidationResult.new
      child.add_error("this is an error")
      grandchild1 = Subvalid::ValidationResult.new
      grandchild1.add_error("this is another error")
      grandchild2 = Subvalid::ValidationResult.new # no errors
      child.children[:bar] = grandchild1
      child.children[:baz] = grandchild2
      subject.children[:foo] = child
      subject.add_error("this is a base error")
    end

    it "generates flat list of error messages recursively" do
      expect(subject.flatten).to eq([
        "this is a base error",
        "foo: this is an error",
        "foo, bar: this is another error"
      ])
    end
  end
end
