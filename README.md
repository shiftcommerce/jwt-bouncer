[![JWT Compatible](https://jwt.io/assets/badge-compatible.svg)](https://jwt.io/)

JwtBouncer is an abstraction for JWT-based authentication/authorisation.

### Usage

#### Parsing incoming requests

JwtBouncer includes a request parser which accepts a standard Rack request object and provides automated decoding and verification of the JWT.

You can then call various methods on this for authorisation. It's best demonstrated through an example:

```ruby
require 'jwt_bouncer/request'

r = JwtBouncer::Request.new(request)

# is the token valid
r.authenticated?

# checks whether permissions has this key and it's truthy
r.can?(:update_product)

# who is authenticated, returns a hash of data
r.actor

# access the raw permissions hash
r.permissions
```

#### Signing outbound requests

JwtBouncer isn't currently designed to provide extensive JWT signing, however it does provide a small service object for signing outbound requests. This can be useful for test suites where you may want to fake a JWT signed request.

```ruby
require 'jwt_bouncer/sign_request'

# assuming you're using rspec-mocks here, but this could be a real request
request = double(:request, headers: {})

# some data to pass in
shared_secret = 'leeroy'
permissions = { update_product: true }
actor = { type: 'user', id: 1, name: 'Jenkins' }

# expiry is optional
expiry = Time.now.to_i + 60

# sign the request
JwtBouncer::SignRequest.call request, shared_secret: shared_secret,
                                      permissions: permissions,
                                      actor: actor,
                                      expiry: expiry

# the request will now have the token in the header
request.headers['Authorization'] # => "Bearer ..."
```

### Contributing

Read the [development documentation](https://github.com/shiftcommerce/jwt-bouncer/blob/master/docs/development.md) to understand how to work on the library locally.

We welcome pull requests.
