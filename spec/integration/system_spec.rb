describe ROM::Auth::System do

  let(:setup)       { ROM.setup(:sql, "sqlite::memory") }
  let(:connection)  { setup.default.connection }

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
    end

    system = ROM::Auth::System.new(config)

    expect{ system.authenticate(nil) }.to raise_error

    creds = OpenStruct.new(identifier: 'test', password: 'test')

    system.authenticate(creds)
  end

end
