require_relative '../minitest_helper'

module GemsLicenseFinder
  class Sanity < GemsLicenseFinder::Unit::TestCase
    def test_rails_gem
      assert_equal({
        :license_type=>"MIT",
        :license_url=>"http://choosealicense.com/licenses/mit/",
        :homepage=>"http://github.com/rails/rails",
        :license=>"https://github.com/rails/rails/blob/master/README.md#license",
        :github_url=>"https://github.com/rails/rails",
        :github_user=>"rails",
        :github_repo=>"rails"
      },GemsLicenseFinder.new().find("rails"))
    end
  end
end

