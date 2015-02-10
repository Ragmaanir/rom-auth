describe 'CommonPlugins' do
  let(:setup)       { ROM.setup(:sql, "sqlite::memory") }
  let(:connection)  { setup.default.connection }

  def password
    'somepassword'
  end

  def password_verifier
    ROM::Auth::PasswordVerifiers::PBKDF2Verifier.for_password(password)
  end

  before do
    connection.create_table(:users) do
      primary_key :id
    end

    class User
      include Virtus.value_object(coerce: false)

      values do
        attribute :id, Integer
      end
    end

    @users = Class.new(ROM::Relation[:sql]) do
      register_as :users
      dataset :users

      def by_id(id)
        where(id: id)
      end
    end

    @mapper = Class.new(ROM::Mapper) do
     relation(:users)
     model(User) # FIXME
    end
  end

  it '#authenticate' do
    config = ROM::Auth::Configuration.new do |c|
      c.plugin(ROM::Auth::Plugins::AuthenticationCredentialsPlugin) do
      end

      c.plugin(ROM::Auth::Plugins::AuthenticationEventsPlugin) do
      end

      c.plugin(ROM::Auth::Plugins::LockdownPlugin) do
      end
    end

    system = ROM::Auth::AuthenticationSystem.new(config)

    system.migrate!(setup)

    rom = ROM.finalize.env

    connection[:users].insert(id: 1)
    connection[:authentication_credentials].insert(
      user_id: 1,
      type: 'email',
      identifier: 'a@b.c.de',
      verifier_data: password_verifier.to_s
    )

    credentials = double(type: 'email', identifier: 'a@b.c.de', password: password)
    user = rom.read(:users).first

    auths = rom.read(:authentication_events)

    assert{ system.authenticate(credentials) == user }
    assert{ auths.count == 1 }

    event = auths.first
    assert{ event.type == 'email' }
    assert{ event.authenticated == true }
    assert{ event.success == true }
    assert{ event.user_id == 1 }
  end

  it '#authenticate lockdown' do
    config = ROM::Auth::Configuration.new do |c|
      c.plugin(ROM::Auth::Plugins::AuthenticationCredentialsPlugin) do
      end

      c.plugin(ROM::Auth::Plugins::AuthenticationEventsPlugin) do
      end

      c.plugin(ROM::Auth::Plugins::LockdownPlugin) do |c|
        c.lock_strategy  = ->(plugin, user, credentials){
          plugin.system.logger.info('LOCKING')
        }
      end
    end

    system = ROM::Auth::AuthenticationSystem.new(config)

    system.migrate!(setup)

    rom = ROM.finalize.env

    connection[:users].insert(id: 1)
    connection[:authentication_credentials].insert(
      user_id: 1,
      type: 'email',
      identifier: 'a@b.c.de',
      verifier_data: password_verifier.to_s
    )

    credentials = double(type: 'email', identifier: 'a@b.c.de', password: 'incorrect')

    user = rom.read(:users).first

    assert{ system.authenticate(credentials) == nil }
  end
end
