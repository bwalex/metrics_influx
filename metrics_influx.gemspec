# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'metrics_influx/version'

Gem::Specification.new do |spec|
  spec.name          = "metrics_influx"
  spec.version       = MetricsInflux::VERSION
  spec.authors       = ["Alex Hornung"]
  spec.email         = ["alex@alexhornung.com"]
  spec.description   = %q{MetricsInflux is a pluggable metrics collector feeding into InfluxDB}
  spec.summary       = spec.description
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.required_ruby_version = '>= 1.9.3'

  spec.add_dependency "thor",      "~> 0.19.1"
  spec.add_dependency "daemons",   "~> 1.1.9"
  spec.add_dependency "celluloid", "~> 0.16.0"
  spec.add_dependency "timers",    "~> 4.0.1"
  spec.add_dependency "json",      "~> 1.8.1"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake", "~> 10.4.2"
  spec.add_development_dependency "rspec", "~> 3.1.0"
end
