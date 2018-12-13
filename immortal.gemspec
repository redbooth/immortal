# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'immortal/version'

Gem::Specification.new do |spec|
  spec.name          = 'immortal'
  spec.version       = Immortal::VERSION
  spec.authors       = [
    'Jordi Romero', 'Saimon Moore', 'Pau Ramon', 'Carlos Saura', 'Andres Bravo',
    'Fran Casas', 'Pau Perez'
  ]
  spec.email         = ['jordi@jrom.net', 'saimon@saimonmoore.net']
  spec.homepage      = 'http://github.com/teambox/immortal'
  spec.summary       = 'Replacement for acts_as_paranoid for Rails 4'
  spec.description   = 'Typical paranoid gem built for Rails 4 and with the ' \
                       "minimum code needed to satisfy acts_as_paranoid's API"
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = %w[lib]

  spec.add_dependency 'activerecord', '>= 4.1.0', '< 5.1'
  spec.add_development_dependency 'appraisal'
  spec.add_development_dependency 'rspec', '~> 3.6.0'
  spec.add_development_dependency 'rspec-its'
  spec.add_development_dependency 'sqlite3' unless ENV['CONFIG_MYSQL']
  spec.add_development_dependency 'byebug'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'rubocop-rspec'
  spec.add_development_dependency 'reek'
end
