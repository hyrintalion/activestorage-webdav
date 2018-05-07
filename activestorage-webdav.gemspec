
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'activestorage-webdav/version'

Gem::Specification.new do |spec|
  spec.name          = 'activestorage-webdav'
  spec.version       = ActivestorageWebdav::VERSION
  spec.authors       = ['Ann Razumova']
  spec.email         = ['hyrintalion@gmail.com']

  spec.homepage      = 'https://github.com/hyrintalion/activestorage-webdav'
  spec.summary       = 'ActiveStorage adapter for WebDAV.'
  spec.description   = 'ActiveStorage adapter for WebDAV.'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'activestorage', '~> 5.2'
  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'

  # Basic dependencies
  spec.add_development_dependency 'webdav-client', '~> 0.0.1'
end
