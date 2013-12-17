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

It parses `~/.aws/config` by default.

If you put a config file like:

    [default]
    aws_access_key_id=DefaultAccessKey01
    aws_secret_access_key=Default/Secret/Access/Key/02
    # Optional, to define default region for this profile.
    region=us-west-1

    [profile testing]
    aws_access_key_id=TestingAccessKey03
    aws_secret_access_key=Testing/Secret/Access/Key/04
    region=us-west-2

you can access it like:

    require "aws_config"
    
    puts AWSConfig.default.aws_access_key_id    #=> DefaultAccessKey01
    puts AWSConfig.default.region               #=> Default/Secret/Access/Key/02

also you can do like hashes:

    puts AWSConfig["default"]["aws_access_key_id"]  #=> DefaultAccessKey01
    puts AWSConfig["default"]["region"]             #=> Default/Secret/Access/Key/02

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
