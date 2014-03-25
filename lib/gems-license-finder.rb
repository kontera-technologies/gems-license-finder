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
    LICENSE_FILES = %w[LICENSE LICENSE.md LICENSE.markdown MIT-LICENSE
                       LICENSE.txt MIT-LICENSE.txt MIT.LICENSE MIT-LICENSE.md
                       COPYING COPYING.md]

    README_FILES = %w[README.md README.rdoc README.markdown README.txt README]

    LICENSES_STRINGS = {
      "mit"      => "Permission is hereby granted",
      "affero"   => "GNU AFFERO",
      "artistic" => "artistic",
      "apache"   => "apache",
      "bsd-3"    => "Neither the name of the",
      "bsd"      => "Redistribution and use in source and binary forms",
      "gpl-3"    => "GNU GENERAL.*?Version 3",
      "gpl"      => "GNU GENERAL",
      "lgpl-3"   => "GNU LESSER GENERAL.*?Version 3",
      "lgpl"     => "GNU LESSER",
      "ruby"     => "You may make and give away verbatim copies"
    }

    def initialize options = {}
      @github = Github.new options.clone
    end

    def find name
      rubygems_info( name ).merge( github_info name )
    end

    private

    def type_from_license_text t
      LICENSES_STRINGS.each {|n,s| return normalize_licence(n) if utf8_match(t,s)}
      nil
    end

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

      type, lurl = []

      LICENSE_FILES.each do |file|
        content = fetch_github_file(user, repo, file)
        info[:license] = "#{url}/blob/master/#{file}" if content

        if info[:license]
          type, lurl = (file =~ /mit/i) ? 
            normalize_licence("mit") : type_from_license_text(content)
          break
        end
      end

      if (!type and gemspec = fetch_github_file(user,repo,"#{name}.gemspec") )
        type, lurl = normalize_licence(gemspec)
      end

      README_FILES.each do |file|
        next if info[:license] and type
        page_url = "https://github.com/#{user}/#{repo}/blob/master/#{file}"
        raw_content = fetch_github_file(user, repo, file)
        content = GitHub::Markup.render(file, raw_content) rescue next
        type, lurl = normalize_licence(content) if content and type.nil?

        info[:license] ||=  page_url + "#" + 
          utf8_match(content,'<h\d+>.*?(license.*?)<\/h\d+>')[1].to_s.downcase.gsub(/\s/,"-") rescue nil

        if info[:license] and type.nil?
          type, lurl = type_from_license_text(content)
        end

      end

      info[:license_type] = type if type
      info[:license_url] = lurl if lurl
      info
    end

    def utf8_match text, regex
       text.force_encoding("utf-8").match Regexp.new(
         regex.force_encoding("utf-8"),
         Regexp::FIXEDENCODING|Regexp::IGNORECASE|Regexp::MULTILINE
       )
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
