# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'rom/auth/version'

Gem::Specification.new do |s|
  s.name        = "rom-auth"
  s.version     = ROM::Auth::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Ragmaanir"]
  s.email       = ["ragmaanir@gmail.com"]
  s.homepage    = "http://github.com/ragmaanir/rom-auth"
  s.summary     = "Simple web-framework independent authentication solution using ROM"
  s.description = "Provides low-level authentication based on ROM. Provides several plugins in order to lockdown accounts on failed authentication and saving events for each authentication attempt."

  s.required_rubygems_version = "~> 2.2"
  s.required_ruby_version     = "~> 2.1"
  s.rubyforge_project         = "rom-auth"

  s.files        = Dir.glob("lib/**/*") + %w(README.md)
  s.test_files   = Dir.glob("spec/**/*_spec.rb")
  s.require_path = 'lib'

  s.add_runtime_dependency 'rom', '~> 0.7.1'
  s.add_runtime_dependency 'rom-sql', '~> 0.5'
  s.add_runtime_dependency 'activesupport', '>= 3.2'
  s.add_runtime_dependency 'virtus', '~> 1.0'
  s.add_runtime_dependency 'ice_nine', '~> 0.11'
  s.add_runtime_dependency 'pbkdf2-ruby', '~> 0.2.1'
  #s.add_runtime_dependency 'logger-better', '~> 0.1'

  #s.add_development_dependency 'database_cleaner', '>= 0'
  s.add_development_dependency "sqlite3", '~> 1.3'
  s.add_development_dependency "rspec", '~> 3.0'
  s.add_development_dependency 'wrong', '~> 0.7'
  s.add_development_dependency 'minitest-stub-const', '~> 0.3'

  s.add_development_dependency 'pry', '~> 0.9'
  s.add_development_dependency 'binding_of_caller', '~> 0.7'
end
