$LOAD_PATH.push File.expand_path('../lib', __FILE__)

Gem::Specification.new do |s|
  s.name        = 'immortal'
  s.version     = '2.0.0'
  s.authors     = [
    'Jordi Romero', 'Saimon Moore', 'Pau Ramon', 'Carlos Saura', 'Andres Bravo',
    'Fran Casas', 'Pau Perez'
  ]
  s.email       = ['jordi@jrom.net', 'saimon@saimonmoore.net']
  s.homepage    = 'http://github.com/teambox/immortal'
  s.summary     = 'Replacement for acts_as_paranoid for Rails 4'
  s.description = 'Typical paranoid gem built for Rails 4 and with the ' \
                  "minimum code needed to satisfy acts_as_paranoid's API"
  s.license     = 'MIT'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {spec}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = ['lib']

  s.add_dependency 'activerecord', '~> 4.0.0'
  s.add_development_dependency 'rspec', '~> 2.6.0'
  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'byebug'
  s.add_development_dependency 'rake', '~> 10.0'
  s.add_development_dependency 'rubocop'
  s.add_development_dependency 'rubocop-rspec'
  s.add_development_dependency 'reek'
end
