# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "immortal"
  s.version     = '0.1.4'
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Jordi Romero", "Saimon Moore"]
  s.email       = ["jordi@jrom.net", "saimon@saimonmoore.net"]
  s.homepage    = "http://github.com/teambox/immortal"
  s.summary     = %q{Replacement for acts_as_paranoid for Rails 3}
  s.description = %q{Typical paranoid gem built for Rails 3 and with the minimum code needed to satisfy acts_as_paranoid's API}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency 'activerecord', '~> 3.0.3'
  s.add_development_dependency 'rspec', '~> 2.3.0'
  s.add_development_dependency 'sqlite3-ruby', '~> 1.3.2'
  s.add_development_dependency 'ruby-debug', '~> 0.10.4'
end
