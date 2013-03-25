# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "high_five/version"

Gem::Specification.new do |s|
  s.name        = "high_five"
  s.version     = HighFive::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Brian Samson"]
  s.email       = ["brian@tenforwardconsulting.com"]
  s.homepage    = ""
  s.summary     = %q{HighFive is a set of build scripts and tools for packing HTML5 apps both for the web and for phonegap}
  s.description = %q{Write a better description}

  s.add_runtime_dependency "thor", "~>0.17.0"
  s.add_runtime_dependency "compass", "~>0.12.2"
  s.add_runtime_dependency "yui-compressor", "~>0.9.6"
  s.add_runtime_dependency "sprockets", "~>2.9.0"
  s.add_development_dependency "rspec", "~>2.13.0"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
