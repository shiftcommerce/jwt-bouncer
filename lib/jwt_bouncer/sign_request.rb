# frozen-string-literal: true
require 'jwt_bouncer/token'
require 'jwt_bouncer/permissions'
require 'zlib'

module JwtBouncer
  module SignRequest
    
    def self.call(request, **options)
      request.headers['Authorization'] = "Bearer #{generate_token(**options)}"
      request
    end

    def self.generate_token(permissions: {}, actor: {}, account_reference:, shared_secret:, expiry: nil)
      payload = {
        permissions: Permissions.compress(permissions),
        actor: actor,
        account_reference: account_reference
      }
      Token.encode(payload, shared_secret, expiry: expiry)
    end
    
  end
end
