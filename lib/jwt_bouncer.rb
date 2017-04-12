require 'jwt_bouncer/version'

module JwtBouncer
  autoload :Request,     'jwt_bouncer/request'
  autoload :SignRequest, 'jwt_bouncer/sign_request'
  autoload :Token,       'jwt_bouncer/token'
  autoload :Permissions, 'jwt_bouncer/permissions'
end
