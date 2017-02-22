# frozen-string-literal: true
require 'jwt_bouncer/token'

module JwtBouncer
  module SignRequest
    def self.call(request, **options)
      request.headers['Authorization'] = "Bearer #{generate_token(**options)}"
      request
    end

    private

    def self.generate_token(permissions: {}, actor: {}, shared_secret:, expiry: nil)
      payload = {
        permissions: permissions,
        actor: actor
      }
      Token.encode(payload, shared_secret, expiry: expiry)
    end
  end
end
