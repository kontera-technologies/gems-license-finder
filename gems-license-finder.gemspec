$:.unshift File.expand_path('../lib', __FILE__)

require 'gems-license-finder/version'
require 'rake'
require 'rubygems/package_task'

Gem::Specification.new do |s|
  s.name                  = "gems-license-finder"
  s.version               = GemsLicenseFinder::VERSION
  s.platform              = Gem::Platform::RUBY
  s.summary               = "Poor man's license finder for rubygems"
  s.description           = "Poor man's license finder for rubygems, that might work"
  s.author                = "Eran"
  s.email                 = "eran@kontera.com"
  s.homepage              = 'http://www.kontera.com'
  s.required_ruby_version = '>= 2.1.0'
  s.files                 = %w(README.md Rakefile Gemfile Gemfile.lock LICENSE) + Dir.glob("{lib,bin}/**/*")
  s.require_path          = "lib"
  s.bindir                = "bin"
  s.executable            = "gems-license-finder"
  s.license               = "MIT"

  s.add_development_dependency 'minitest', "~> 5.11.3"
  s.add_development_dependency 'mocha', "~> 1.6.0"

  s.add_dependency "github_api", "~> 0.19.0"
  s.add_dependency "rack", "~> 2.2.3"
  s.add_dependency "github-markup", "~> 3.0.5"
  s.add_dependency "posix-spawn", "~> 0.3.15"
  s.add_dependency "redcarpet", "~> 3.5.1"
  s.add_dependency "rdiscount", "~> 2.2.0"
  s.add_dependency "maruku", "~> 0.7.3"
  s.add_dependency "kramdown", "~> 2.3.0"
  s.add_dependency "bluecloth", "~> 2.2.0"
  s.add_dependency "faraday", "~> 1.3.0"
  
end
