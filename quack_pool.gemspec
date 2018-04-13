Gem::Specification.new do |s|
  s.name        = 'quack_pool'
  s.version     = '0.0.1'
  s.date        = '2018-04-13'
  s.summary     = 'A simple resource pool'
  s.description = "A simple resource pool that accepts a resource class to build the pool's resources from."
  s.authors     = 'Rob Fors'
  s.email       = 'mail@robfors.com'
  s.files       = Dir.glob("{lib,spec}/**/*") + %w(Rakefile LICENSE README.md)
  s.homepage    = 'https://github.com/robfors/quack_pool'
  s.license     = 'MIT'
  s.add_runtime_dependency 'reentrant_mutex', '~> 1'
end
