describe ROM::Auth::Plugins::AuthenticationEventsPlugin do
  let(:setup)       { ROM.setup(:sql, "sqlite::memory") }
  let(:connection)  { setup.default.connection }

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
        :id, :user_id, :started_at, :ended_at, :authenticator, :authenticated, :success, :data
      ]
    }
  end

  it 'ROM::Auth#authenticate' do
    config = ROM::Auth::Configuration.new do |c|
      c.plugin(described_class) do |c|
        c.table_name = :auth_events
      end
    end

    connection.create_table(:users) do
      primary_key :id
    end

    system = ROM::Auth::AuthenticationSystem.new(config)
    system.migrate!(setup)

    rom = ROM.finalize.env

    connection[:users].insert(id: 1)
    user = double(:user, id: 1)

    auths = rom.read(:auth_events)

    assert{ system.authenticate(:password, user, 'somepassword') }
    assert{ auths.count == 1 }

    event = auths.first
    assert{ event.authenticator == 'password' }
    assert{ event.authenticated == true }
    assert{ event.success == true }
    assert{ event.user_id == 1 }
  end

end
