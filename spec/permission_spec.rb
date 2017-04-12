require 'active_support/core_ext/hash/indifferent_access'
require 'jwt_bouncer/permissions'

RSpec.describe JwtBouncer::Permissions do
  describe '.destructure' do
    it 'destructures a simple permission' do
      # Arrange
      permissions = { 'App' => { 'Entity' => ['create'] } }

      # Act
      destructured = JwtBouncer::Permissions.destructure(permissions)

      # Assert
      expect(destructured).to eq(['App_Entity_create'])
    end

    it 'ignores a resource with empty permissions' do
      # Arrange
      permissions = { 'App' => { 'Entity' => [] } }

      # Act
      destructured = JwtBouncer::Permissions.destructure(permissions)

      # Assert
      expect(destructured).to eq([])
    end

    it 'returns multiple permissions for a resource' do
      # Arrange
      permissions = { 'App' => { 'Entity' => %w(create read) } }

      # Act
      destructured = JwtBouncer::Permissions.destructure(permissions)

      # Assert
      expect(destructured).to eq(%w(App_Entity_create App_Entity_read))
    end

    it 'returns multuple service and resource permissions' do
      # Arrange
      permissions = {
        'App1' => { 'Entity' => %w(create read) },
        'App2' => { 'Entity' => ['read'] },
        'App3' => { 'Entity1' => ['read'], 'Entity2' => ['create'] }
      }

      # Act
      destructured = JwtBouncer::Permissions.destructure(permissions)

      # Assert
      expect(destructured).to eq(%w(
                                   App1_Entity_create
                                   App1_Entity_read
                                   App2_Entity_read
                                   App3_Entity1_read
                                   App3_Entity2_create
                                 ))
    end
  end
end
