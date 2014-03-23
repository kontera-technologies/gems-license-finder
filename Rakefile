$:.unshift File.expand_path '../lib', __FILE__
require 'gems-license-finder'
require 'rubygems/package_task'
require 'rake/testtask'

GemsLicenseFinder::GemSpec = eval File.read 'gems-license-finder.gemspec'

Gem::PackageTask.new GemsLicenseFinder::GemSpec do |p|
  p.gem_spec = GemsLicenseFinder::GemSpec
end

## Tests stuff
task :default => :test

Rake::TestTask.new(:test) do |t|
  t.libs.push 'tests'
  t.pattern = 'tests/**/*_test.rb'
end
