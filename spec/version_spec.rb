RSpec.describe 'Version' do
  it 'should return 0.1.0' do
    expect(JwtBouncer::VERSION).to eq('0.1.0')
  end
end
