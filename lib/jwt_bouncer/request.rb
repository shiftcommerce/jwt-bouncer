# frozen-string-literal: true

require 'jwt_bouncer/token'
require 'jwt_bouncer/permissions'
require 'jwt'

module JwtBouncer
  class Request
    HEADER = 'Authorization'

    def initialize(request, shared_secret: nil)
      @encoded_token = Request.extract_token(request)
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

    def account_reference
      decoded_token["account_reference"]
    end
    
    def permissions
      @permissions ||= Permissions.decompress(decoded_token['permissions'])
    end

    def can?(action)
      destructured_action_permissions = Permissions.destructure(action)
      matching_permissions = destructured_action_permissions & destructured_permissions
      matching_permissions == destructured_action_permissions
    end

    # extracts the encoded token from the given request
    def self.extract_token(request)
      return nil unless request.headers.key?(HEADER)
      matches = request.headers.fetch(HEADER).match(/\ABearer\s(.*)\z/i)
      matches[1] if matches
    end

    private

    def decoded_token
      @decoded_token ||= Token.decode(@encoded_token, @shared_secret)
    end

    def destructured_permissions
      Permissions.destructure(permissions)
    end
    
  end
end
