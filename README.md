# QuackPool
*QuackPool* is a ruby gem. It is a simple resource pool that accepts a resource class to build the pool's resources from.

# Features
* thread safe
* only builds new resources as needed
* you can specify a max resource limit

# Intall
`gem install quack_pool`

# Example
```ruby
require 'quack_pool'

class Resource
end

# unlimited resources
pool = QuackPool.new(resource_class: Resource)
resource1 = pool.release_resource
resource2 = pool.release_resource
# use resources ...
pool.absorb_resource(resource1)
pool.absorb_resource(resource2)

# limited resources
pool = QuackPool.new(resource_class: Resource, size: 2)
resource1 = pool.release_resource
thread = Thread.new do
  resource2 = pool.release_resource
  # use resource ...
  sleep 2
  pool.absorb_resource(resource1)
end
sleep 1
resource3 = pool.release_resource # will block until a resource is available
# use resources ...
pool.absorb_resource(resource1)
pool.absorb_resource(resource3)
thread.join

```
