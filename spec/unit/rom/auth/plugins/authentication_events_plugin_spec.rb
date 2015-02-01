describe ROM::Auth::Plugins::AuthenticationEventsPlugin do
  let(:setup) { ROM.setup(:sql, "sqlite::memory") }

  before do
    # FIXME required to reset configuration
    ROM::Auth.configure do
    end
  end

  it '#configure plugin' do
    ROM::Auth.configure do |c|
      c.plugin(:authentication_events) do |c|
        c.table_name = 'lolerskates'
      end
    end

    ROM::Auth.initialize

    assert{ ROM::Auth.loaded_plugins.keys == [:authentication_events] }
    assert{ ROM::Auth.loaded_plugins[:authentication_events].configuration.table_name == :lolerskates }
  end

  it '#migrate' do
    ROM::Auth.configure do |c|
      c.plugin(:authentication_events) do |c|
        c.table_name = 'lolerskates'
      end
    end

    ROM::Auth.initialize
    ROM::Auth.migrate(setup)
    ROM.finalize

    assert{
      setup.default.connection.schema(:lolerskates).map{|c| c.first} == [
        :id, :user_id, :started_at, :ended_at, :authenticator, :authenticated, :success, :data
      ]
    }
  end

  it 'ROM::Auth#authenticate' do
    ROM::Auth.configure do |c|
      c.plugin(:authentication_events) do |c|
        c.table_name = :auth_events
      end
    end

    ROM::Auth.initialize
    ROM::Auth.migrate(setup)
    ROM.finalize

    ROM::Auth.authenticate()
  end

end
