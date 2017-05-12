# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rgss3/version'

Gem::Specification.new do |spec|
  spec.name          = "rgss3"
  spec.version       = RGSS3::VERSION
  spec.authors       = ["taroxd"]
  spec.email         = ["taroxd@outlook.com"]

  spec.summary       = 'Ruby implementation of RGSS3.'
  spec.homepage      = "https://github.com/taroxd/RGSS3"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  # if spec.respond_to?(:metadata)
  #   spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  # else
  #   raise "RubyGems 2.0 or newer is required to protect against " \
  #     "public gem pushes."
  # end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.required_ruby_version = '>= 2.3'

  spec.add_runtime_dependency 'gosu', '~> 0.12'
  spec.add_runtime_dependency 'rmagick', '~> 2.16'
  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 10.0"

  spec.requirements << 'Q8 versions of ImageMagick 6 is recommended'
end
