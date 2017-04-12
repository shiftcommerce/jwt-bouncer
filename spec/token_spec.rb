require 'jwt_bouncer/token'
require 'active_support/core_ext/hash/indifferent_access'
require 'jwt'

RSpec.describe JwtBouncer::Token do
  describe '.decode' do
    context 'with a valid expiry' do
      it 'should return the input data' do
        # Arrange
        shared_secret = 'some_shared_key'

        input_data = {
          permissions: {
            'App1' => { 'Entity' => %w(create read) },
            'App2' => { 'Entity' => ['read'] },
            'App3' => { 'Entity1' => ['read'], 'Entity2' => ['create'] }
          }
        }.with_indifferent_access

        # Act
        encoded_token = described_class.encode(input_data, shared_secret, expiry: Time.now.utc.to_i + 30)
        decoded_token = described_class.decode(encoded_token, shared_secret)

        # Assert
        expect(decoded_token).to eq(input_data)
      end
    end

    context 'with an invalid expiry' do
      it 'should raise an error' do
        # Arrange
        shared_secret = 'some_shared_key'

        input_data = {
          permissions: {
            'App1' => { 'Entity' => %w(create read) },
            'App2' => { 'Entity' => ['read'] },
            'App3' => { 'Entity1' => ['read'], 'Entity2' => ['create'] }
          }
        }.with_indifferent_access

        # Act
        encoded_token = described_class.encode(input_data, shared_secret, expiry: Time.now.utc.to_i - 30)

        # Assert
        expect do
          described_class.decode(encoded_token, shared_secret)
        end.to raise_error(JWT::ExpiredSignature)
      end
    end

    context 'with an invalid shared secret' do
      it 'should raise an error' do
        # Arrange
        shared_secret = 'some_shared_key'

        input_data = {
          permissions: {
            'App1' => { 'Entity' => %w(create read) },
            'App2' => { 'Entity' => ['read'] },
            'App3' => { 'Entity1' => ['read'], 'Entity2' => ['create'] }
          }
        }.with_indifferent_access

        # Act
        encoded_token = described_class.encode(input_data, shared_secret)

        # Assert
        expect do
          described_class.decode(encoded_token, 'invalid_key')
        end.to raise_error(JWT::VerificationError)
      end
    end
  end
end
