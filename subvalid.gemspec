# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "subvalid/version"

Gem::Specification.new do |spec|
  spec.name          = "subvalid"
  spec.version       = Subvalid::VERSION
  spec.authors       = ["Julian Doherty"]
  spec.email         = ["madlep@madlep.com"]
  spec.summary       = %q{Subjective validation for Plain Old Ruby Objects}
  spec.description   = %q{Subvalid allows you to use a familiar syntax to define validator classes to validate plain objects. Rather than hard coding single validation logic into the objects themselves, different validation logic can be used depending on the context.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 12.3"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "pry"
end
