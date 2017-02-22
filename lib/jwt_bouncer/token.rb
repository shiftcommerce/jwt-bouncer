# frozen-string-literal: true
require 'jwt'

module JwtBouncer
  module Token
    ALGORITHM = 'HS256'

    def self.encode(data, shared_secret, expiry:)
      payload = {
        data: data,
        exp: expiry.to_i
      }
      JWT.encode(payload, shared_secret, ALGORITHM)
    end

    def self.decode(token, shared_secret)
      JWT.decode(token, shared_secret, true, { algorithm: ALGORITHM })[0]['data']
    end
  end
end
