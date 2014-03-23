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
    -t, --token TOKEN                github token string ( or by GITHUB_TOEKN environment variable )

More information about how to generate the github token please look at:
https://help.github.com/articles/git-over-https-using-oauth-token
```

finding the license of `bundler` gem
```
$ gems-license-finder bundler --output json
{
  "license_type": "MIT",
  "license_url": "http://choosealicense.com/licenses/mit/",
  "homepage": "http://github.com/carlhuda/bundler/",
  "license": "https://github.com/bundler/bundler/blob/master/LICENSE.md",
  "github_url": "https://github.com/bundler/bundler",
  "github_user": "bundler",
  "github_repo": "bundler"
}

```

Github token is optional, it allows authenticated users to submit more than 20 requests per
minute

```
$ GITHUB_TOEKN=mygithubtoken gems-license-finder rails --output json
{
  "license_type": "MIT",
  "license_url": "http://choosealicense.com/licenses/mit/",
  "homepage": "http://github.com/rails/rails",
  "license": "https://github.com/rails/rails/blob/master/README.md#license",
  "github_url": "https://github.com/rails/rails",
  "github_user": "rails",
  "github_repo": "rails"
}
```
or 
```
$ gems-license-finder redis --output json --token mygithubtoken
{
  "license_type": "MIT",
  "license_url": "http://choosealicense.com/licenses/mit/",
  "homepage": "https://github.com/redis/redis-rb",
  "license": "https://github.com/redis/redis-rb/blob/master/LICENSE",
  "github_url": "https://github.com/redis/redis-rb",
  "github_user": "redis",
  "github_repo": "redis-rb"

```
via code

```ruby
require 'gems-license-finder'
require 'pp'

client = GemsLicenseFinder.new(oauth_token: "MY-GITHUB-TOKEN")
pp client.find("rails")

# this should be printed to the console

{:license_type=>"MIT",
 :license_url=>"http://choosealicense.com/licenses/mit/",
 :homepage=>"http://github.com/rails/rails",
 :license=>"https://github.com/rails/rails/blob/master/README.md#license",
 :github_url=>"https://github.com/rails/rails",
 :github_user=>"rails",
 :github_repo=>"rails"}
```

## Warranty
This software is provided "as is" and without any express or implied warranties, including, without limitation, the implied warranties of merchantability and fitness for a particular purpose.

