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
Usage: gems-license-finder [gem-name | Gemfile.lock] [options]

    -o, --output FORMAT              output format [json, yaml]
    -t, --token TOKEN                github token string ( or by GITHUB_TOKEN environment variable )
    -p, --parallel X                 number of threads to use
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

finding licenses for gems listed in Gemfile.lock
```
$ cat /your/project/path/Gemfile.lock
GEM
  remote: https://rubygems.org/
  specs:
    eventmachine (1.2.7)
    zscheduler (0.0.8)
      eventmachine

PLATFORMS
  ruby

DEPENDENCIES
  zscheduler!

BUNDLED WITH
   1.17.3

$ gems-license-finder /your/project/path/Gemfile.lock

{
  "eventmachine": {
    "homepage": "http://rubyeventmachine.com",
    "source_code": "https://github.com/eventmachine/eventmachine",
    "documentation": "https://www.rubydoc.info/gems/eventmachine/1.2.7",
    "bug_tracker": "https://github.com/eventmachine/eventmachine/issues",
    "download": "/downloads/eventmachine-1.2.7.gem",
    "reverse_dependencies": "/gems/eventmachine/reverse_dependencies",
    "license_type": "Ruby",
    "license_url": "https://www.ruby-lang.org/en/about/license.txt",
    "description": "EventMachine implements a fast, single-threaded engine for arbitrary networkcommunications. It's extremely easy to use in Ruby. EventMachine wraps allinteractions with IP sockets, allowing programs to concentrate on theimplementation of network protocols. It can be used to create both networkservers and clients. To create a server or client, a Ruby program only needsto specify the IP address and port, and provide a Module that implements thecommunications protocol. Implementations of several standard network protocolsare provided with the package, primarily to serve as examples. The real goalof EventMachine is to enable programs to easily interface with other programsusing TCP/IP, especially if custom protocols are required.",
    "license": "https://github.com/eventmachine/eventmachine/blob/master/LICENSE",
    "github_url": "https://github.com/eventmachine/eventmachine"
  },
  "zscheduler": {
    "homepage": "http://github.com/eranb/zscheduler",
    "source_code": "https://github.com/eranb/zscheduler",
    "documentation": "https://www.rubydoc.info/gems/zscheduler/0.0.8",
    "download": "/downloads/zscheduler-0.0.8.gem",
    "reverse_dependencies": "/gems/zscheduler/reverse_dependencies",
    "license_type": "LGPL",
    "license_url": "http://choosealicense.com/licenses/lgpl-v2.1/",
    "description": "minimalistic scheduler on top of event-machine",
    "license": "https://github.com/eranb/zscheduler/blob/master/LICENSE",
    "github_url": "https://github.com/eranb/zscheduler"
  }
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

