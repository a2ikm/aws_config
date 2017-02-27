require "aws_config/version"
require "aws_config/profile_resolver"
require "aws_config/parser"

module AWSConfig
  extend self

  def profiles
    @profiles ||= begin
      resolver = ProfileResolver.new
      resolver.add(config_profiles)
      resolver.add(credentials_profiles)
      resolver.profiles
    end
  end

  def config_file
    ENV["AWS_CONFIG_FILE"] || File.join(ENV["HOME"], ".aws/config")
  end

  def config_profiles
    return {} unless File.exists?(config_file)

    Parser.parse(File.read(config_file))
  end

  def credentials_file
    ENV["AWS_SHARED_CREDENTIALS_FILE"] || File.join(ENV["HOME"], ".aws/credentials")
  end

  def credentials_profiles
    return {} unless File.exists?(credentials_file)

    Parser.parse(File.read(credentials_file))
  end

  def [](profile)
    profiles[profile.to_s]
  end

  def respond_to?(id, include_all = false)
    profiles.has_key?(id.to_s) || super
  end

  def method_missing(id, *args)
    self[id] || super
  end
end
