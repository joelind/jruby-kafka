Gem::Specification.new do |spec|
  files = []
  dirs = %w{ lib }
  dirs.each do |dir|
    files += Dir["#{dir}/**/*"]
  end

  spec.name          = "jruby-kafka"
  spec.version       = "0.0.1"
  spec.authors       = ["Joseph Lawson"]
  spec.email         = ["joe@joekiller.com"]
  spec.description   = "this is primarily to be used as an interface for logstash"
  spec.summary       = "jruby Kafka wrapper"
  spec.homepage      = "https://github.com/joekiller/jruby-kafka"
  spec.license       = "MIT"

  spec.files         = files
  spec.require_paths << "lib"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
