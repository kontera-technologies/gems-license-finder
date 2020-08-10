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
  s.author                = "Eran Barak Levi"
  s.email                 = "eran@kontera.com"
  s.homepage              = 'http://www.kontera.com'
  s.required_ruby_version = '>= 1.9.1'
  s.files                 = %w(README.md Rakefile Gemfile Gemfile.lock LICENSE) + Dir.glob("{lib,bin}/**/*")
  s.require_path          = "lib"
  s.bindir                = "bin"
  s.executable            = "gems-license-finder"

  s.add_development_dependency 'minitest'
  s.add_development_dependency 'mocha'

  s.add_dependency "github_api"
  s.add_dependency "rack", ">= 2.1.4"
  s.add_dependency "github-markup"
  s.add_dependency "posix-spawn"
  s.add_dependency "redcarpet"
  s.add_dependency "rdiscount"
  s.add_dependency "maruku"
  s.add_dependency "kramdown", ">= 2.3.0"
  s.add_dependency "bluecloth"
  s.add_dependency "faraday", "< 0.9" # stupid warning on 0.9.X
  
end
