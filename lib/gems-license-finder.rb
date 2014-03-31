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
                       LICENSE.txt MIT-LICENSE.txt MIT.LICENSE MIT_LICENSE 
                       MIT-LICENSE.md LICENSE.rdoc License
                       COPYING License.txt COPYING.md GNU GNU.txt GNU.rdoc GNU.markdown]

    README_FILES = %w[README.md README.rdoc README.markdown README.txt README README.textile]

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
      normalize(github_info name, rubygems_info( name ))
    end

    private

    def rubygems_info name
      begin
        content = open("http://rubygems.org/gems/#{name}").read
      rescue Exception => e
        raise e.io.status.first == "404" ? GemNotFound.new(e) : e
      end

      info = Hash[content.scan(/<a href="(.*?)" rel.*>(.*?)</)].invert
      type, url = normalize_licence(
        (utf8_match(content,'<h5>Licenses<\/h5>.*?<p>(.*?)<')[1]  rescue ""))
      description = (utf8_match(content,'<div id="markup">.*?<p>(.*?)<')[1].
                     strip.squeeze(" ").gsub(/\n/,"") rescue nil)

      info.merge({ license_type: type, license_url: url, description: description })
    end

    def github_info name, rubygems
      url = rubygems["Source Code"] || rubygems["Homepage"]
      if url.to_s =~ /\/\/github\.com/
        # Sometimes the homepage in rubygems.org is old, e.g:
        # carlhuda/bundler => bundler/bundler
        open(url.sub("http:","https:")) { |o| url = o.base_uri.to_s } # follow redirects
      else
        url = nil
      end

      url ||= find_github_url name
      user, repo, type, lurl, license = URI(url).path.split("/")[1..2]

      LICENSE_FILES.each do |file|
        content = fetch_github_file(user, repo, file)
        license = "#{url}/blob/master/#{file}" if content

        if license
          type, lurl = (file =~ /mit|gnu/i) ? 
            normalize_licence(file.split(".").first) : type_from_license_text(content)
          break
        end
      end

      if (!type and gemspec = fetch_github_file(user,repo,"#{name}.gemspec") )
        type, lurl = normalize_licence(gemspec)
      end

      README_FILES.each do |file|
        break if license and type 
        content = GitHub::Markup.render(file,fetch_github_file(user,repo,file)) rescue next
        type, lurl = normalize_licence(content) if type.nil?

        rurl = "https://github.com/#{user}/#{repo}/blob/master/#{file}"

        license ||= rurl + "#" + utf8_match(content,'<h\d+>[\s|\t]*(license.*?)<\/h\d+>')[1].
          to_s.downcase.gsub(/\s/,"-") rescue nil

        if license.nil? and utf8_match(content,'licen[cs]e')
          license = rurl 
          type, lurl = normalize_licence content
        end

        type, lurl = type_from_license_text(content) if license and type.nil?
        break if content
      end

      info = {license: license, github_url: url}
      info[:license_type] = type if type
      info[:license_url] = lurl if lurl
      rubygems.merge info
    end

    def utf8_match text, regex
       text.force_encoding("utf-8").match Regexp.new(
         regex.force_encoding("utf-8"),
         Regexp::FIXEDENCODING|Regexp::IGNORECASE|Regexp::MULTILINE
       )
    end

    def find_github_url name
      (@github.search.repos(q: "#{name} language:ruby").to_a[1][1][0] ||
       @github.search.repos(q: "ruby #{name}").to_a[1][1][0]).html_url
    end

    def fetch_github_file user, repo, file
      begin
        Base64.decode64(@github.repos.contents.get(user, repo, file).content)
      rescue Github::Error::NotFound
      end
    end

    def type_from_license_text t
      LICENSES_STRINGS.each {|n,s| return normalize_licence(n) if utf8_match(t,s)}
      nil
    end

    def normalize hash
      Hash[hash.map {|k,v| [k.to_s.downcase.gsub(/\s/,"_"),v]}]
    end

    def normalize_licence str
      case str.downcase
      when /(^|\W)mit(\W|$)/i
        ["MIT","http://choosealicense.com/licenses/mit/"]
      when /(^|\W)bsd\W.*?3/i
        ["BSD-3","http://choosealicense.com/licenses/bsd-3-clause/"]
      when /(^|\W)bsd(\W|$)/i
        ["BSD","http://choosealicense.com/licenses/bsd/"]
      when /(^|\W)apache(\W|$)/i
        ["Apache","http://choosealicense.com/licenses/apache/"]
      when /(^|\W)lgpl\W.*?3/i
        ["LGPL-3","http://choosealicense.com/licenses/lgpl-v3/"]
      when /(^|\W)lgpl(\W|$)/i
        ["LGPL","http://choosealicense.com/licenses/lgpl-v2.1/"]
      when /(affero)|(agpl)/i
        ["Affero-GPL","http://choosealicense.com/licenses/agpl/"]
      when /(^|\W)gpl\W.*?3/i
        ["GPL-3","http://choosealicense.com/licenses/gpl-v3/"]
      when /(^|\W)gpl(\W|$)/i
        ["GPL-2","http://choosealicense.com/licenses/gpl-v2/"]
      when /(^|\W)artistic(\W|$)/i
        ["Artistic","http://choosealicense.com/licenses/artistic/"]
      when /(licen[sc]e.*?ruby)|(ruby.*?licen[sc]e)/msi
        ["Ruby","https://www.ruby-lang.org/en/about/license.txt"]
      when "ruby"
        ["Ruby","https://www.ruby-lang.org/en/about/license.txt"]
      else
        nil
      end
    end

  end
end
