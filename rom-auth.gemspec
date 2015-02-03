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
  s.summary     = ""
  s.description = ""

  s.required_rubygems_version = "~> 2.2"
  s.required_ruby_version     = "~> 2.1"
  s.rubyforge_project         = "rom-auth"

  #s.add_runtime_dependency 'rom', '~> 0.5'
  #s.add_runtime_dependency 'rom-sql', '~> 0.3.2'
  s.add_runtime_dependency 'rack', '~> 1.6'
  s.add_runtime_dependency 'activesupport', '~> 4.2'
  s.add_runtime_dependency 'virtus', '~> 1.0'
  s.add_runtime_dependency 'ice_nine', '~> 0.11'
  #s.add_runtime_dependency 'descendants_tracker', '~> 0.0', '>= 0.0.4'
  #s.add_runtime_dependency 'pbkdf2', '~> 0.2.2', git: 'git://github.com/emerose/pbkdf2-ruby.git'

  s.add_development_dependency "sqlite3", '~> 1.3'
  s.add_development_dependency "rspec", '~> 3.0'
  s.add_development_dependency 'wrong', '~> 0.7'
  s.add_development_dependency 'minitest-stub-const', '~> 0.3'

  s.add_development_dependency 'pry', '~> 0.9'
  s.add_development_dependency 'binding_of_caller', '~> 0.7'

  s.files        = Dir.glob("lib/**/*") + %w(README.txt)
  s.test_files   = Dir.glob("spec/**/*_spec.rb")
  s.require_path = 'lib'
end
