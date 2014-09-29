# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'api_tools/version'

Gem::Specification.new do |spec|
  spec.name          = 'api_tools'
  spec.version       = APITools::VERSION
  spec.authors       = ['Andrew Ryan Lazarus']
  spec.email         = ['nerdrew@gmail.com']
  spec.summary       = %q{Tools for APIs}
  spec.description   = %q{}
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']


  spec.add_runtime_dependency 'activesupport', '>= 4.0'
  spec.add_runtime_dependency 'activerecord', '>= 4.0'
  spec.add_runtime_dependency 'actionpack', '>= 4.0'
  spec.add_runtime_dependency 'railties', '>= 4.0'
  spec.add_runtime_dependency 'uuid'
  spec.add_runtime_dependency 'rake'
  spec.add_runtime_dependency 'rake-hooks'

  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'appraisal', '~> 0.5.1'
  spec.add_development_dependency 'pry-nav'
  spec.add_development_dependency 'api_tools_specs'
end
