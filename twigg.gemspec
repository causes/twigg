# coding: utf-8
lib = File.expand_path('lib', File.dirname(__FILE__))
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'twigg'

Gem::Specification.new do |spec|
  spec.name          = 'twigg'
  spec.version       = Twigg::VERSION
  spec.authors       = ['Causes Engineering']
  spec.email         = ['eng@causes.com']
  spec.summary       = 'Statistics for Git repositories'
  spec.description   = <<-EOS.strip.gsub(/\s+/, ' ')
    Twigg provides stats for activity in Git repositories. It includes
    command-line and web-based interfaces.
  EOS
  spec.homepage      = 'https://github.com/causes/twig'
  spec.license       = 'MIT'

  spec.files         = Dir['bin/*', 'lib/**/*']
  spec.executables   = ['twigg']
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'shotgun'
  spec.add_development_dependency 'rspec'

  spec.add_dependency 'haml', '~> 4.0.3'
  spec.add_dependency 'sinatra-contrib', '~> 1.4.0'
end
