# frozen-string-literal: true
require 'jwt'

module JwtBouncer
  module Token
    ALGORITHM = 'HS256'

    def self.encode(data, shared_secret, expiry: nil)
      # setup our base payload
      payload = { data: data, iat: Time.now.utc.to_i }
      # apply expiry, if necessary
      payload[:exp] = expiry.to_i if expiry
      # build the JWT
      JWT.encode(payload, shared_secret, ALGORITHM)
    end

    def self.decode(token, shared_secret)
      JWT.decode(token, shared_secret, true, algorithm: ALGORITHM, verify_iat: true).dig(0, 'data')
    end
  end
end
