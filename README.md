# Gems License Finder

Poor man's implementation of a license finder for rubygems.
<br/>It uses `rubygems.org` && `Github` under the hood and **works 90% of the time** :)

## WARNING
Please be aware that it may give you the WRONG license for some of the gems,
so use it at your own risk

## Installtion
`gem install gems-license-finder`

or add this to your `Gemfile` and bundle

`gem 'gems-license-finder'`

## Usage
via command line
```
$ gems-license-finder --help
Usage: gems-license-finder gem-name [options]

    -o, --output FORMAT              output format [json, yaml]
    -t, --token TOKEN                github token string ( or by GITHUB_TOKEN environment variable )
    -v, --version                    Print version and exit

For more information about how to generate the github token please look at:
https://help.github.com/articles/git-over-https-using-oauth-token
```

finding the license of `bundler` gem
```
$ gems-license-finder bundler
{
  "homepage": "http://bundler.io",
  "source_code": "http://github.com/carlhuda/bundler/",
  "documentation": "http://gembundler.com",
  "mailing_list": "http://groups.google.com/group/ruby-bundler?hl=en",
  "bug_tracker": "http://github.com/carlhuda/bundler/issues",
  "license_type": "MIT",
  "license_url": "http://choosealicense.com/licenses/mit/",
  "description": "Bundler manages an application&#x27;s dependencies through its entire life, across many machines, systematically and repeatably",
  "license": "https://github.com/bundler/bundler//blob/master/LICENSE.md",
  "github_url": "https://github.com/bundler/bundler/"
}

```

Github token is optional, it allows authenticated users to submit more than 20 requests per
minute

```
$ GITHUB_TOKEN=mygithubtoken gems-license-finder rails
{
  "homepage": "http://www.rubyonrails.org",
  "source_code": "http://github.com/rails/rails",
  "documentation": "http://api.rubyonrails.org",
  "wiki": "http://wiki.rubyonrails.org",
  "mailing_list": "http://groups.google.com/group/rubyonrails-talk",
  "bug_tracker": "http://github.com/rails/rails/issues",
  "license_type": "MIT",
  "license_url": "http://choosealicense.com/licenses/mit/",
  "description": "Ruby on Rails is a full-stack web framework optimized for programmer happiness and sustainable productivity. It encourages beautiful code by favoring convention over configuration.",
  "license": "https://github.com/rails/rails/blob/master/README.md#license",
  "github_url": "https://github.com/rails/rails"
}
```
or via the `--token` switch
```
$ gems-license-finder redis --token mygithubtoken
{
  "homepage": "https://github.com/redis/redis-rb",
  "license_type": "MIT",
  "license_url": "http://choosealicense.com/licenses/mit/",
  "description": "A Ruby client that tries to match Redis&#x27; API one-to-one, while still providing an idiomatic interface. It features thread-safety, client-side sharding, pipelining, and an obsession for performance.",
  "license": "https://github.com/redis/redis-rb/blob/master/LICENSE",
  "github_url": "https://github.com/redis/redis-rb"
}
```
via code

```ruby
require 'gems-license-finder'
require 'pp'

client = GemsLicenseFinder.new(oauth_token: "MY-GITHUB-TOKEN")
pp client.find("rails")

# this should be printed to the console
{
  "homepage"=>"http://www.rubyonrails.org",
  "source_code"=>"http://github.com/rails/rails",
  "documentation"=>"http://api.rubyonrails.org",
  "wiki"=>"http://wiki.rubyonrails.org",
  "mailing_list"=>"http://groups.google.com/group/rubyonrails-talk",
  "bug_tracker"=>"http://github.com/rails/rails/issues",
  "license_type"=>"MIT",
  "license_url"=>"http://choosealicense.com/licenses/mit/",
  "license"=>"https://github.com/rails/rails/blob/master/README.md#license",
  "github_url"=>"https://github.com/rails/rails"
}
```

## Warranty
This software is provided "as is" and without any express or implied warranties, including, without limitation, the implied warranties of merchantability and fitness for a particular purpose.

