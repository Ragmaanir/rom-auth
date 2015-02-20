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
    conn = Sequel.connect('sqlite:memory')
    conn.tables.each{ |t| conn.drop_table?(t) }

    stub_const("ROM::Auth::PasswordVerifiers::PasswordVerifier::DEFAULT_OPTIONS", ROM::Auth::PasswordVerifiers::PasswordVerifier::DEFAULT_OPTIONS.merge(:iterations => 1))
  end

end
