# describe ROM::Auth::Services::PasswordAuthenticationService do

#   before do
#     s = ROM.setup(:sql, "sqlite::memory")

#     ROM::Auth.initialize
#     ROM::Auth.migrate(s)
#     @rom = ROM.finalize.env
#   end

#   def service
#     @service ||= described_class.new(ROM::Auth)
#   end

#   def password
#     'somepassword'
#   end

#   def password_verifier
#     ROM::Auth::PBKDF2Verifier.for_password(password)
#   end

#   it '#authenticate logs the login event when correct password passed' do
#     user = double(:user, id: 1, password_verifier: password_verifier, can_login?: true)

#     assert{ service.authenticate(user, password) }

#     login_events = @rom.read(:user_login_events)
#     assert{ login_events.count == 1 }
#     assert{ login_events.first.success == true }
#   end

#   it '#authenticate logs the login attempt when incorrect password passed' do
#     user = double(:user, id: 1, password_verifier: password_verifier, can_login?: true)

#     assert{ !service.authenticate(user, 'incorrect') }

#     login_events = @rom.read(:user_login_events)

#     assert{ login_events.count == 1 }
#     assert{ login_events.first.success == false }
#   end

#   it '#authenticate logs the login attempt when user inactive but password correct' do
#     user = double(:user, id: 1, password_verifier: password_verifier, can_login?: false)

#     assert{ !service.authenticate(user, password) }

#     login_events = @rom.read(:user_login_events)

#     assert{ login_events.count == 1 }
#     assert{ login_events.first.success == false }
#   end

# end
