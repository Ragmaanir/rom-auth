require 'wrong'
require 'pry'

require "rom-auth"

ENV['ROM_AUTH_ENV'] = 'test'

RSpec.configure do |c|
  include Wrong::Assert
  Wrong.config.colors
  c.filter_run :focus => true
  c.run_all_when_everything_filtered = true

  c.before do
    #@constants = Object.constants
    conn = Sequel.connect('sqlite:memory')
    conn.tables.each{ |t| conn.drop_table?(t) }
  end

  c.after do
    [ROM::Relation, ROM::Mapper, ROM::Command].each { |klass| clear_descendants(klass) }
    #added_constants = Object.constants - @constants
    #added_constants.each { |name| Object.send(:remove_const, name) }
  end

  def clear_descendants(klass)
    klass.descendants.each { |d| clear_descendants(d) }
    klass.instance_variable_set('@descendants', [])
  end

  c.before do
    stub_const("ROM::Auth::PasswordVerifier::DEFAULT_OPTIONS", ROM::Auth::PasswordVerifier::DEFAULT_OPTIONS.merge(:iterations => 1))
  end
end
