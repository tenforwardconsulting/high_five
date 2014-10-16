# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "high_five/version"

Gem::Specification.new do |s|
  s.name        = "high_five"
  s.version     = HighFive::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Brian Samson"]
  s.email       = ["brian@tenforwardconsulting.com"]
  s.homepage    = "http://github.com/tenforwardconsulting/high_five"
  s.summary     = %q{HighFive is a set of build scripts and tools for packing HTML5 apps both for the web and for phonegap}
  s.description = %q{Build, minify, and deal with different platforms and environments for your HTML5 app.
    This is often used with PhoneGap but designed not to require it, and high_five can be used to deploy any kind of HTML/JS/CSS-based
    application that requires different deployment configurations.
  }

  s.add_dependency 'multi_json', '~> 1.0'
  s.add_runtime_dependency "thor", "~>0.18.0"
  s.add_runtime_dependency "compass", "~>0.12.2"
  s.add_runtime_dependency "yui-compressor", "~>0.9.6"
  s.add_runtime_dependency "uglifier", "~>2.1.1"
  s.add_runtime_dependency "sprockets", ">=2.0"
  s.add_runtime_dependency "coffee-script", "~>2.2.0"
  s.add_runtime_dependency "plist", ">=3.0"
  s.add_runtime_dependency "nokogiri", ">=1.5.0"
  s.add_runtime_dependency "chunky_png"
  s.add_runtime_dependency "webrick"
  s.add_development_dependency "rspec", "~>2.13.0"


  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
