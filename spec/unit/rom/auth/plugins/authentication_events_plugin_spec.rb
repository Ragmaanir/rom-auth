describe ROM::Auth::Plugins::AuthenticationEventsPlugin do
  let(:setup)       { ROM.setup(:sql, "sqlite::memory") }
  let(:connection)  { setup.default.connection }

  def password
    'somepassword'
  end

  def password_verifier
    ROM::Auth::PasswordVerifiers::PBKDF2Verifier.for_password(password)
  end

  it '#configure plugin' do
    config = ROM::Auth::Configuration.new do |c|
      c.plugin(described_class) do |c|
        c.table_name = 'lolerskates'
      end
    end

    system = ROM::Auth::AuthenticationSystem.new(config)

    assert{ system.plugins.keys == [described_class] }
    assert{ system.plugins[described_class].configuration.table_name == :lolerskates }
  end

  it '#migrate' do
    config = ROM::Auth::Configuration.new do |c|
      c.plugin(described_class) do |c|
        c.table_name = 'lolerskates'
      end
    end

    system = ROM::Auth::AuthenticationSystem.new(config)
    system.migrate!(setup)

    ROM.finalize

    assert{
      setup.default.connection.schema(:lolerskates).map{|c| c.first} == [
        :id, :user_id, :started_at, :ended_at,
        :identifier, :type, :authenticated, :success, :data
      ]
    }
  end

  it 'ROM::Auth::System#authenticate' do
    config = ROM::Auth::Configuration.new do |c|
      c.plugin(ROM::Auth::Plugins::AuthenticationCredentialsPlugin) do
      end

      c.plugin(described_class) do |c|
        c.table_name = :auth_events
      end
    end

    class User
      include Virtus.value_object(coerce: false)

      values do
        attribute :id, Integer
      end
    end

    @users = Class.new(ROM::Relation[:sql]) do
      base_name :users

      def by_id(id)
        where(id: id)
      end
    end

    @mapper = Class.new(ROM::Mapper) do
      relation(:users)
      model(User) # FIXME
    end

    connection.create_table(:users) do
      primary_key :id
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
    user = double(:user, id: 1, password_verifier: password_verifier)

    auths = rom.read(:auth_events)

    assert{ system.authenticate(credentials) }
    assert{ auths.count == 1 }

    event = auths.first
    assert{ event.type == 'email' }
    assert{ event.authenticated == true }
    assert{ event.success == true }
    assert{ event.user_id == 1 }
  end

end
