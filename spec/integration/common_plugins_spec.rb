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

  it '#authenticate with AuthenticationCredentialsPlugin' do
    config = ROM::Auth::Configuration.new do |c|
      c.plugin(ROM::Auth::Plugins::AuthenticationCredentialsPlugin) do
      end

      c.plugin(ROM::Auth::Plugins::AuthenticationEventsPlugin) do
      end
    end

    system = ROM::Auth::System.new(config)

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
    user = rom.relation(:users).first

    assert{ system.authenticate(credentials) == user }
  end

  it '#authenticate with AuthenticationEventsPlugin' do
    config = ROM::Auth::Configuration.new do |c|
      c.plugin(ROM::Auth::Plugins::AuthenticationCredentialsPlugin) do
      end

      c.plugin(ROM::Auth::Plugins::AuthenticationEventsPlugin) do
      end

      c.plugin(ROM::Auth::Plugins::LockdownPlugin) do
      end
    end

    system = ROM::Auth::System.new(config)

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
    user = rom.relation(:users).first

    auths = rom.relation(:authentication_events)

    assert{ system.authenticate(credentials) == user }
    assert{ auths.relation.count == 1 }

    event = auths.as(:rom_auth_event).first
    assert{ event.type == 'email' }
    assert{ event.authenticated == true }
    assert{ event.success == true }
    assert{ event.user_id == 1 }
  end

  it '#authenticate with LockdownPlugin' do
    config = ROM::Auth::Configuration.new do |c|
      c.plugin(ROM::Auth::Plugins::AuthenticationCredentialsPlugin) do
      end

      c.plugin(ROM::Auth::Plugins::AuthenticationEventsPlugin) do
      end

      c.plugin(ROM::Auth::Plugins::LockdownPlugin) do |c|
        c.lock_strategy  = ->(plugin, user_id, credentials){
          #plugin.system.logger.info('LOCKING')
          plugin.lock(user_id, 'Login failed')
        }
      end
    end

    system = ROM::Auth::System.new(config)

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

    user = rom.relation(:users).first

    assert{ system.authenticate(credentials) == nil }

    lock = rom.relation(:rom_auth_lockdowns).as(:rom_auth_lockdown).first

    assert{ lock.locked_at.close_to?(Time.now, 1) }
    assert{ lock.lock_reason == 'Login failed' }

    plugin = system.plugins[ROM::Auth::Plugins::LockdownPlugin]
    assert{ plugin.is_locked?(lock.id) == true }

    plugin.unlock(lock.id)
    assert{ plugin.is_locked?(lock.id) == false }

    lock = rom.relation(:rom_auth_lockdowns).as(:rom_auth_lockdown).first
    assert{ lock.locked_at == nil }
    assert{ lock.lock_reason == nil }
  end
end
