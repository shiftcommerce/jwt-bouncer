require 'active_support/core_ext/hash/indifferent_access'
require 'jwt_bouncer/permissions'

RSpec.describe JwtBouncer::Permissions do

  describe '.destructure' do
  
      it 'destructures a simple permission' do
        # Arrange
        permissions = {'PIM' => { 'Product' => [ 'create' ]}}
        
        # Act
        destructured = JwtBouncer::Permissions.destructure(permissions)
        
        # Assert
        expect(destructured).to eq(['PIM_Product_create'])
      end
    
      it 'ignores a resource with empty permissions' do
        # Arrange
        permissions = { 'PIM' => { 'Product' => [ ] }}
        
        # Act
        destructured = JwtBouncer::Permissions.destructure(permissions)
        
        # Assert
        expect(destructured).to eq([ ])
      end
    
      it 'returns multiple permissions for a resource' do
        # Arrange
        permissions = { 'PIM' => {'Product' => [ 'create', 'read' ]}}
        
        # Act
        destructured = JwtBouncer::Permissions.destructure(permissions)
        
        # Assert
        expect(destructured).to eq([ 'PIM_Product_create', 'PIM_Product_read' ])
      end
    
      it 'returns multuple service and resource permissions' do
        # Arrange
        permissions = {
          'PIM' => { 'Product' => [ 'create', 'read' ] },
          'OMS' => { 'StockLevel' => [ 'read' ] },
          'Inventory' => { 'StockLevel' => [ 'read' ], 'StockAllocation' => [ 'create' ] }
        }
        
        # Act
        destructured = JwtBouncer::Permissions.destructure(permissions)
        
        # Assert
        expect(destructured).to eq([
                                     'PIM_Product_create',
                                     'PIM_Product_read',
                                     'OMS_StockLevel_read',
                                     'Inventory_StockLevel_read',
                                     'Inventory_StockAllocation_create'
                                   ])
      end
  end
  
end