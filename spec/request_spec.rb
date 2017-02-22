require 'active_support/core_ext/hash/indifferent_access'
require 'jwt_bouncer/request'
require 'jwt_bouncer/token'

RSpec.describe JwtBouncer::Request do
  describe '#authenticated?' do
    context 'with no Authorization header' do
      it 'should return false' do
        # Arrange
        request = double(:request, headers: {})

        # Act
        authenticated = described_class.new(request, shared_secret: 'bla').authenticated?

        # Assert
        expect(authenticated).to eq(false)
      end
    end

    context 'with an invalid Authorization header' do
      it 'should return false' do
        # Arrange
        request = double(:request, headers: { 'Authorization' => 'blablabla' })

        # Act
        authenticated = described_class.new(request, shared_secret: 'bla').authenticated?

        # Assert
        expect(authenticated).to eq(false)
      end
    end

    context 'with a valid Authorization header, but invalid JWT token' do
      it 'should return false' do
        # Arrange
        request = double(:request, headers: { 'Authorization' => 'Bearer blablabla' })

        # Act
        authenticated = described_class.new(request, shared_secret: 'bla').authenticated?

        # Assert
        expect(authenticated).to eq(false)
      end
    end

    context 'with a valid Authorization header with a valid JWT token' do
      it 'should return true' do
        # Arrange
        token = JwtBouncer::Token.encode({ test: true }, 'secret')
        request = double(:request, headers: { 'Authorization' => "Bearer #{token}" })

        # Act
        authenticated = described_class.new(request, shared_secret: 'secret').authenticated?

        # Assert
        expect(authenticated).to eq(true)
      end
    end
  end

  describe '#actor' do
    it 'should return the actor property from the encoded data' do
      # Arrange
      actor_input = { name: 'Dave', id: 123, type: 'User' }.with_indifferent_access
      token = JwtBouncer::Token.encode({ actor: actor_input }, 'secret')
      request = double(:request, headers: { 'Authorization' => "Bearer #{token}" })

      # Act
      actor = described_class.new(request, shared_secret: 'secret').actor

      # Assert
      expect(actor).to eq(actor_input)
    end
  end

  describe '#can?' do
    context 'when the permission exists and is true' do
      it 'should return true' do
        # Arrange
        token = JwtBouncer::Token.encode({ permissions: { update_product: true } }, 'secret')
        request = double(:request, headers: { 'Authorization' => "Bearer #{token}" })

        # Act
        allowed = described_class.new(request, shared_secret: 'secret').can?(:update_product)

        # Assert
        expect(allowed).to eq(true)
      end
    end

    context 'when the permission exists and is false' do
      it 'should return false' do
        # Arrange
        token = JwtBouncer::Token.encode({ permissions: { update_product: false } }, 'secret')
        request = double(:request, headers: { 'Authorization' => "Bearer #{token}" })

        # Act
        allowed = described_class.new(request, shared_secret: 'secret').can?(:update_product)

        # Assert
        expect(allowed).to eq(false)
      end
    end

    context 'when the permission does not exist' do
      it 'should return false' do
        # Arrange
        token = JwtBouncer::Token.encode({ permissions: {} }, 'secret')
        request = double(:request, headers: { 'Authorization' => "Bearer #{token}" })

        # Act
        allowed = described_class.new(request, shared_secret: 'secret').can?(:update_product)

        # Assert
        expect(allowed).to eq(false)
      end
    end
  end
end
