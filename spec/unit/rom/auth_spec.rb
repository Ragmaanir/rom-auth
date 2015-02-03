describe ROM::Auth do

  # let(:setup) { ROM.setup(:sql, "sqlite::memory") }

  # def password
  #   'somepassword'
  # end

  # def password_verifier
  #   ROM::Auth::PBKDF2Verifier.for_password(password)
  # end

  # before do
  #   # FIXME required to reset configuration
  #   ROM::Auth.configure do
  #   end
  # end

  # it '#authenticators' do
  #   assert{
  #     described_class.authenticators == {
  #       :password => ROM::Auth::Authenticators::PasswordAuthenticator
  #     }
  #   }
  # end

  # it '#configure' do
  #   described_class.configure do |c|
  #     c.users_table_name = :accounts
  #   end

  #   assert{ described_class.configuration.users_table_name == :accounts }
  # end

  # it '#configure plugins' do
  #   described_class.configure do |c|
  #     c.plugin(ROM::Auth::Plugins::AuthenticationEventsPlugin) do |c|
  #       c.table_name = 'lolerskates'
  #     end
  #   end

  #   described_class.initialize

  #   assert{ described_class.loaded_plugins.keys == [:authentication_events] }
  #   assert{ described_class.loaded_plugins[:authentication_events].configuration.table_name == :lolerskates }
  # end

  # it '#migrate' do
  #   described_class.configure do |c|
  #     c.plugin(ROM::Auth::Plugins::AuthenticationEventsPlugin) do |c|
  #       c.table_name = 'lolerskates'
  #     end
  #   end

  #   described_class.initialize
  #   described_class.migrate(setup)

  #   assert{ described_class.loaded_plugins.keys == [:authentication_events] }
  #   assert{ described_class.loaded_plugins[:authentication_events].configuration.table_name == :lolerskates }
  # end

  # it '#authenticate' do
  #   described_class.initialize
  #   described_class.migrate(setup)

  #   rom = ROM.finalize.env

  #   rom.read(:users).to_a

  #   user = double(:user, id: 1, password_verifier: password_verifier)

  #   assert{ described_class.authenticate(:password, user, 'somepassword') }
  # end

end
