# encoding: utf-8

require 'github_api'
require 'open-uri'
require 'uri'
require 'github/markup'
require 'gems-license-finder/version'

module GemsLicenseFinder
  GemNotFound = Class.new(StandardError)

  def self.new(*args)
    Client.new(*args)
  end

  def self.version
    GemsLicenseFinder::VERSION
  end

  class Client

    LICENSE_FILES = %w[LICENSE LICENSE.md LICENSE.markdown MIT-LICENSE LICENSE.txt
      MIT-LICENSE.txt MIT.LICENSE MIT-LICENSE.md  COPYING COPYING.md]
    README_FILES = %w[README.md README.rdoc README.markdown README.txt README]

    def initialize options = {}
      @github = Github.new options.clone
    end

    def find name
      rubygems_info( name ).merge( github_info name )
    end

    private

    def rubygems_info name
      begin
        content = open("http://rubygems.org/gems/#{name}").read
      rescue Exception => e
        raise e.io.status.first == "404" ? GemNotFound.new(e) : e
      end

      homepage = nil
      type, url = normalize_licence(
        (content.match(/<h5>Licenses<\/h5>.*?<p>(.*?)</msi)[1]  rescue ""))
      homepage = (content.match(/<a href="(.*?)".*?>Source/)[1] rescue nil)
      homepage ||= (content.match(/<a href="(.*?)".*?>Home/)[1] rescue nil)

      { license_type: type, license_url: url, homepage: homepage }
    end

    def github_info name
      url = find_github_url name
      user, repo = URI(url).path.split("/")[1..2]
      info = {license: nil, github_url: url, github_user: user, github_repo: repo}

      LICENSE_FILES.each do |file|
        info[:license] = "#{url}/blob/master/#{file}" if fetch_github_file(user, repo, file)

        if info[:license]
          info[:license_type], info[:license_url] = normalize_licence("mit") if file =~ /mit/i
          break
        end
      end

      if (!info[:license_type] and gemspec = fetch_github_file(user,repo,"#{name}.gemspec") )
        info[:license_type], info[:license_url] = normalize_licence(gemspec)
      end

      README_FILES.each do |file|
        next if info[:license]
        page_url = "https://github.com/#{user}/#{repo}/blob/master/#{file}"
        raw_content = fetch_github_file(user, repo, file)
        content = GitHub::Markup.render(file, raw_content) rescue next

        if content and info[:license_type].nil?
          info[:license_type], info[:license_url] = normalize_licence(content) 
        end

        msi = Regexp::FIXEDENCODING | Regexp::IGNORECASE | Regexp::MULTILINE
        regex = Regexp.new('<h\d+>.*?(license.*?)<\/h\d+>'.force_encoding("UTF-8"),msi)
        info[:license] =  page_url + "#" + 
          content.match(regex)[1].to_s.downcase.gsub(/\s/,"-") rescue nil
      end

      info
    end

    def find_github_url name
      @github.search.repos(q: "#{name} language:ruby").to_a[1][1][0].html_url
    end

    def fetch_github_file user, repo, file
      begin
        Base64.decode64(@github.repos.contents.get(user, repo, file).content)
      rescue Github::Error::NotFound
      end
    end

    def normalize_licence str
      case str.downcase
      when /(^|\W)mit(\W|$)/
        ["MIT","http://choosealicense.com/licenses/mit/"]
      when /(^|\W)bsd\W.*?3/
        ["BSD-3","http://choosealicense.com/licenses/bsd-3-clause/"]
      when /(^|\W)bsd(\W|$)/
        ["BSD","http://choosealicense.com/licenses/bsd/"]
      when /(^|\W)apache(\W|$)/
        ["Apache","http://choosealicense.com/licenses/apache/"]
      when /(^|\W)lgpl\W.*?3/
        ["LGPL-3","http://choosealicense.com/licenses/lgpl-v3/"]
      when /(^|\W)lgpl(\W|$)/
        ["LGPL","http://choosealicense.com/licenses/lgpl-v2.1/"]
      when /(affero)|(agpl)/
        ["Affero-GPL","http://choosealicense.com/licenses/agpl/"]
      when /(^|\W)gpl\W.*?3/
        ["GPL-3","http://choosealicense.com/licenses/gpl-v3/"]
      when /(^|\W)gpl(\W|$)/
        ["GPL-2","http://choosealicense.com/licenses/gpl-v2/"]
      when /(^|\W)artistic(\W|$)/
        ["Artistic","http://choosealicense.com/licenses/artistic/"]
      when /(license.*?ruby)|(ruby.*?license)/
        ["Ruby","https://www.ruby-lang.org/en/about/license.txt"]
      when "ruby"
        ["Ruby","https://www.ruby-lang.org/en/about/license.txt"]
      else
        nil
      end
    end

  end
end
