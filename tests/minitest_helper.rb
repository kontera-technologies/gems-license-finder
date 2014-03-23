$:.unshift File.expand_path '../../lib', __FILE__
gem 'minitest'

require 'minitest/autorun'
require 'mocha/setup'
require 'gems-license-finder'

module GemsLicenseFinder
  module Unit
    class TestCase < ::Minitest::Unit::TestCase
    end
  end
end
