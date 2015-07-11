describe ROM::Auth::System do

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
      c.plugin(ROM::Auth::Plugins::AuthenticationCredentialsPlugin)
    end

    system = ROM::Auth::System.new(config)

    system.migrate!(setup)

    rom = ROM.finalize.env

    expect{ system.authenticate(nil) }.to raise_error

    connection[:users].insert(id: 1)
    connection[:authentication_credentials].insert(
      user_id: 1,
      type: 'email',
      identifier: 'a@b.c.de',
      verifier_data: password_verifier.to_s
    )

    creds = OpenStruct.new(identifier: 'a@b.c.de', type: 'email', password: password)

    assert{ system.authenticate(creds) }
  end

end
