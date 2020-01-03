# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'aws_config/version'

Gem::Specification.new do |spec|
  spec.name          = "aws_config"
  spec.version       = AWSConfig::VERSION
  spec.authors       = ["Masato Ikeda"]
  spec.email         = ["masato.ikeda@gmail.com"]
  spec.description   = %q{AWSConfig is a parser for AWS_CONFIG_FILE used in aws-cli.}
  spec.summary       = %q{AWSConfig is a parser for AWS_CONFIG_FILE used in aws-cli.}
  spec.homepage      = "https://github.com/a2ikm/aws_config"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", ">= 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
