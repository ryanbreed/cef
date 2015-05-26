# -*- encoding: utf-8 -*-

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cef/version'

Gem::Specification.new do |spec|
  spec.name    = "cef"
  spec.version = CEF::VERSION

  spec.authors     = ["Ryan Breed"]
  spec.date        = "2011-03-30"
  spec.description = %q{ format/send CEF logs via API+syslog or client program }
  spec.summary     = %q{ CEF Generation Library and Client }
  spec.email       = %q{ opensource@breed.org }

  spec.extra_rdoc_files = [ "LICENSE.txt", "README.rdoc" ]
  spec.homepage         = "http://github.com/ryanbreed/cef"
  spec.licenses         = ["MIT"]

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.require_paths    = ["lib"]

  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "bundler"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "pry"

end

