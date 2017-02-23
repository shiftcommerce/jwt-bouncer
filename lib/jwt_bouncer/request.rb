# frozen-string-literal: true
require 'jwt_bouncer/token'
require 'jwt'

module JwtBouncer
  class Request
    HEADER = 'Authorization'

    def initialize(request, shared_secret: nil)
      @encoded_token = extract_token(request)
      @shared_secret = shared_secret
    end

    def authenticated?
      !!decoded_token
    rescue JWT::DecodeError
      false
    end

    def actor
      decoded_token['actor']
    end

    def permissions
      decoded_token['permissions']
    end

    def can?(action)
      permissions && !!permissions[action.to_s]
    end

    private

    def decoded_token
      @decoded_token ||= Token.decode(@encoded_token, @shared_secret)
    end

    # extracts the encoded token from the given request
    def extract_token(request)
      return nil unless request.headers.key?(HEADER)
      matches = request.headers.fetch(HEADER).match(/\ABearer\s(.*)\z/i)
      matches[1] if matches
    end
  end
end
