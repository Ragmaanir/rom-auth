describe ROM::Auth::PasswordVerifiers::PBKDF2Verifier do

  let(:password)  { 'somelongpw123,.-' }
  let(:salt)      { 'AAFF435' }
  let(:verifier)  { described_class.for_password(password, :salt => salt, :iterations => 2) }

  describe '#initialize' do
    it { assert{ verifier.class == ROM::Auth::PasswordVerifiers::PBKDF2Verifier } }
    it { assert{ verifier.salt == salt } }
    it { assert{ verifier.digest.is_a?(ROM::Auth::Digest) } }
    it { assert{ verifier.digest.to_s == PBKDF2.new(:password => password, :salt => salt, :iterations => 2).hex_string } }
  end

  describe '#verifies' do
    it { assert{ verifier.verifies?(password) } }
    it { assert{ !verifier.verifies?('incorrect password') } }
    it { assert{ !verifier.verifies?('') } }
  end

  describe '#to_s' do
    it { assert{ verifier.to_s == "PBKDF2,#{salt},#{verifier.digest},2" } }
  end

  describe '.from_s' do
    it { assert{ described_class.from_s(verifier.to_s) == verifier } }
    it { assert{ described_class.from_s(verifier.to_s).to_s == verifier.to_s } }
    it { assert{ described_class.from_s(verifier.to_s).verifies?(password) } }
  end

end
