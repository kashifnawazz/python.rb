# -*- mode: ruby -*-
# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'python/version'

Gem::Specification.new do |spec|
  spec.name          = "python"
  spec.version       = Python::VERSION
  spec.authors       = ["Kensuke Sawada"]
  spec.email         = ["sasasawada@gmail.com"]
  spec.summary       = %q{Python in Ruby}
  spec.description   = %q{Python implemented purely in Ruby without any library}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
end
