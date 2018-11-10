# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'api_auth/client/version'

Gem::Specification.new do |spec|
  spec.name          = 'api_auth-client'
  spec.version       = ApiAuth::Client::VERSION
  spec.authors       = ['Genaro Madrid']
  spec.email         = ['genmadrid@gmail.com']

  spec.summary       = 'Base ApiClient'
  spec.description   = 'ApiClient for simple api calls integrated with api-auth gem'
  spec.homepage      = 'https://github.com/Mifiel/api-auth-client'

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'api-auth', '> 1.4'
  spec.add_dependency 'rest-client', '> 1.7'

  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'coveralls'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rubocop', '~> 0.60'
  spec.add_development_dependency 'rubocop-rspec'
  spec.add_development_dependency 'webmock', '~> 3.4'
end
