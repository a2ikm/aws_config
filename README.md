# AWSConfig

AWSConfig is a parser for AWS_CONFIG_FILE used in [aws-cli](https://github.com/aws/aws-cli).

## Installation

Add this line to your application's Gemfile:

    gem 'aws_config'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install aws_config

## Usage

It parses `~/.aws/config` and `~/.aws/credentials` by default.

If your aws config files look like this:

**Credentials file**
```
  [default]
  aws_access_key_id=DefaultAccessKey01
  aws_secret_access_key=Default/Secret/Access/Key/02

  [testing]
  aws_access_key_id=TestingAccessKey03
  aws_secret_access_key=Testing/Secret/Access/Key/04
```

**Config file**
```
  [default]
  # Optional, to define default region for this profile.
  region=us-west-1
  source_profile=default

  [profile testing]
  role_arn=arn:example:283671836
  region=us-west-2
  source_profile=testing

  [profile with_mfa]
  source_profile=testing
  region=ap-southeast-2
  mfa_serial=arn:mfa_device:151235152134
```

you can access it like:
```ruby
  require "aws_config"

  puts AWSConfig.default.aws_access_key_id    #=> DefaultAccessKey01
  puts AWSConfig.default.region               #=> Default/Secret/Access/Key/02
```

also you can do like hashes:
```ruby
  puts AWSConfig["default"]["aws_access_key_id"]  #=> DefaultAccessKey01
  puts AWSConfig["default"]["region"]             #=> Default/Secret/Access/Key/02
```

If your config contains chained profiles using the `source_profile` property,
you can still access the source profiles properties from the top i.e
```ruby
  require 'aws_config'

  puts AWSConfig.with_mfa.role_arn #=> arn:example:283671836
  puts AWSConfig.with_mfa.region   #=> ap-southeast-2
```

If you want to use with aws-sdk-ruby, you can configure like:
```ruby
  AWS.config(AWSConfig.default.config_hash)
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
