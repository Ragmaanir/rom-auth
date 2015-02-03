describe 'CommonPlugins' do
  let(:setup)       { ROM.setup(:sql, "sqlite::memory") }
  let(:connection)  { setup.default.connection }

  def password
    'somepassword'
  end

  def password_verifier
    ROM::Auth::PBKDF2Verifier.for_password(password)
  end

  before do
    connection.create_table(:users) do
      primary_key :id
    end
  end

  it '#authenticate' do
    config = ROM::Auth::Configuration.new do |c|
      c.plugin(ROM::Auth::Plugins::AuthenticationCredentialsPlugin) do
      end

      c.plugin(ROM::Auth::Plugins::AuthenticationEventsPlugin) do
      end
    end

    system = ROM::Auth::AuthenticationSystem.new(config)

    system.migrate!(setup)

    rom = ROM.finalize.env

    connection[:users].insert(id: 1)
    user = double(:user, id: 1, password_verifier: password_verifier)

    auths = rom.read(:authentication_events)

    assert{ system.authenticate(:password, user, 'somepassword') }
    assert{ auths.count == 1 }

    event = auths.first
    assert{ event.authenticator == 'password' }
    assert{ event.authenticated == true }
    assert{ event.success == true }
    assert{ event.user_id == 1 }
  end
end
