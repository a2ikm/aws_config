require "aws_config/profile_resolver"
module AWSConfig
  module Store
    def profiles
      @profiles ||= begin
        if File.exist?(config_file)
          profile_resolver = ProfileResolver.new
          profile_resolver.add Parser.parse(File.read(credentials_file), true)
          profile_resolver.add Parser.parse(File.read(config_file))
          profile_resolver.profiles
        else
          Hash.new
        end
      end
    end

    def config_file
      @config_file || ENV["AWS_CONFIG_FILE"] || File.join(ENV["HOME"], ".aws/config")
    end

    def config_file=(path)
      @config_file = path
      @profiles = nil
    end

    def credentials_file
      @credentials_file || ENV["AWS_SHARED_CREDENTIALS_FILE"] || File.join(ENV["HOME"], ".aws/credentials")
    end

    def credentials_file=(path)
      @credentials_file = path
      @profiles = nil
    end

    def [](profile)
      profiles[profile.to_s]
    end

    def has_profile?(profile)
      profiles.has_key?(profile.to_s)
    end

    def respond_to?(id, include_all = false)
      has_profile?(id) || super
    end

    def method_missing(id, *args)
      if has_profile?(id)
        self[id]
      else
        super
      end
    end
  end
end
