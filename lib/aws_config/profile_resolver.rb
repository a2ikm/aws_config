require "aws_config/profile"

module AWSConfig
  class ProfileResolver
    attr_reader :profiles, :wanted_profiles

    def initialize
      @profiles = {}
      @wanted_profiles = {}
    end

    def add(profs)
      profs.each do |name, profile|
        if profiles.key? name
          profiles[name].merge! profile
        else
          profiles[name] = profile
        end
        resolve_source_profile(name, profile) if profile.has_key? "source_profile"
        provides_source_profile(name, profile)
      end
    end

    private

    def resolve_source_profile(name, profile)
      source_profile = profile.source_profile
      if profiles.key? source_profile
        profile["source_profile"] = profiles[source_profile]
      else
        (wanted_profiles[source_profile] ||= []) << name
      end
    end

    def provides_source_profile(name, profile)
      return unless wanted_profiles.key? name
      wanted_profiles[name].each do |wanted_by|
        profiles[wanted_by]["source_profile"] = profile
      end
      wanted_profiles.delete name
    end
  end
end
