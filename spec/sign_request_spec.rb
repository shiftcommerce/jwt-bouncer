require 'jwt_bouncer/sign_request'
require 'jwt_bouncer/request'

RSpec.describe JwtBouncer::SignRequest do
  describe '.call' do
    it 'should apply an Authorization bearer header' do
      # Arrange
      shared_secret = 'test'
      request = double(:request, headers: {})

      # Act
      described_class.call(request, shared_secret: 'test', account_reference: 'ac', permissions: { 'App' => { 'Entity' => ['create'] } })

      # Assert
      token_regexp = /\ABearer\s(.*)\z/i
      expect(request.headers['Authorization']).to match(token_regexp)
    end

    it 'should be parsable' do
      # Arrange
      shared_secret = 'test'
      request = double(:request, headers: {})

      # Act
      described_class.call(request, shared_secret: shared_secret, account_reference: 'ac', permissions: { 'App' => { 'Entity' => ['create'] } })

      # Assert
      parsed_request = JwtBouncer::Request.new(request, shared_secret: shared_secret)
      expect(parsed_request.authenticated?).to eq(true)
      expect(parsed_request.can?({ 'App' => { 'Entity' => ['create'] } } )).to eq(true)
    end
  end
end
