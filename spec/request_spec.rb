require 'active_support/core_ext/hash/indifferent_access'
require 'jwt_bouncer/request'
require 'jwt_bouncer/token'
require 'jwt_bouncer/permissions'

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
    context 'when the permission exists and is allowed' do
      it 'should return true' do
        # Arrange
        permissions = JwtBouncer::Permissions.compress('App' => { 'Entity' => ['create'] })
        token = JwtBouncer::Token.encode({ permissions: permissions }, 'secret')
        request = double(:request, headers: { 'Authorization' => "Bearer #{token}" })

        # Act
        allowed = described_class.new(request, shared_secret: 'secret').can?('App' => { 'Entity' => ['create'] })

        # Assert
        expect(allowed).to eq(true)
      end
    end

    context 'when the permission is complex and is allowed' do
      it 'should return true' do
        # Arrange
        permissions = JwtBouncer::Permissions.compress('App' => { 'Enity1' => ['read'], 'Entity2' => ['create'] })
        token = JwtBouncer::Token.encode({ permissions: permissions }, 'secret')
        request = double(:request, headers: { 'Authorization' => "Bearer #{token}" })

        # Act
        allowed = described_class.new(request, shared_secret: 'secret').can?('App' => { 'Enity1' => ['read'], 'Entity2' => ['create'] })

        # Assert
        expect(allowed).to eq(true)
      end

      it 'should return true' do
        # Arrange
        permissions = JwtBouncer::Permissions.compress('App1' => { 'Entity1' => ['read'], 'Entity2' => ['create'] },
                                                       'App2' => { 'Entity' => ['create'] })
        token = JwtBouncer::Token.encode({ permissions: permissions }, 'secret')
        request = double(:request, headers: { 'Authorization' => "Bearer #{token}" })

        # Act
        allowed = described_class.new(request, shared_secret: 'secret').can?('App2' => { 'Entity' => ['create'] },
                                                                             'App1' => { 'Entity1' => ['read'] })

        # Assert
        expect(allowed).to eq(true)
      end
    end

    context 'with multiple permissions for resources and requested check' do
      it 'should return true' do
        # Arrange
        permissions = JwtBouncer::Permissions.compress('App1' => { 'Entity1' => ['create', 'read'], 'Entity2' => ['create'] },
                                                       'App2' => { 'Entity' => ['create'] },
                                                       OMS: { PlaceOrder: [:create] })
        token = JwtBouncer::Token.encode({ permissions: permissions }, 'secret')
        request = double(:request, headers: { 'Authorization' => "Bearer #{token}" })

        # Act
        allowed = described_class.new(request, shared_secret: 'secret').can?('App2' => { Entity: ['create'] },
                                                                             App1: { 'Entity1' => ['read', :create] })

        # Assert
        expect(allowed).to eq(true)
      end
    end

    context 'when the permission is complex and some are allowed' do
      it 'should return false' do
        # Arrange
        permissions = JwtBouncer::Permissions.compress('App1' => { 'Entity' => ['create'] },
                                                       'App2' => { 'Entity' => ['create'] })
        token = JwtBouncer::Token.encode({ permissions: permissions }, 'secret')
        request = double(:request, headers: { 'Authorization' => "Bearer #{token}" })

        # Act
        allowed = described_class.new(request, shared_secret: 'secret').can?('App2' => { 'Entity' => ['create'] },
                                                                             'App1' => { 'Entity' => ['read'] })

        # Assert
        expect(allowed).to eq(false)
      end
    end

    context 'when the permission exists and is not allowed' do
      it 'should return false' do
        # Arrange
        permissions = JwtBouncer::Permissions.compress('App' => { 'Entity' => [] })
        token = JwtBouncer::Token.encode({ permissions: permissions }, 'secret')
        request = double(:request, headers: { 'Authorization' => "Bearer #{token}" })

        # Act
        allowed = described_class.new(request, shared_secret: 'secret').can?('App' => { 'Entity' => ['create'] })

        # Assert
        expect(allowed).to eq(false)
      end
    end

    context 'when the permission does not exist' do
      it 'should return false' do
        # Arrange
        permissions = JwtBouncer::Permissions.compress({})
        token = JwtBouncer::Token.encode({ permissions: permissions }, 'secret')
        request = double(:request, headers: { 'Authorization' => "Bearer #{token}" })

        # Act
        allowed = described_class.new(request, shared_secret: 'secret').can?('App' => { 'Entity' => ['create'] })

        # Assert
        expect(allowed).to eq(false)
      end
    end

    context 'when the permission uses symbols is complex and is allowed' do
      it 'should return true' do
        # Arrange
        permissions = JwtBouncer::Permissions.compress(App1: { Entity1: [:read], Entity2: [:create] },
                                                       App2: { Entity: [:create] })
        token = JwtBouncer::Token.encode({ permissions: permissions }, 'secret')
        request = double(:request, headers: { 'Authorization' => "Bearer #{token}" })

        # Act
        allowed = described_class.new(request, shared_secret: 'secret').can?('App2' => { 'Entity' => ['create'] },
                                                                             'App1' => { 'Entity1' => ['read'] })

        # Assert
        expect(allowed).to eq(true)
      end
    end
  end
end
