module AWSConfig
  class ProfileResolver
    attr_reader :profiles

    def initialize
      @profiles = {}
    end

    def add(profiles_hash)
      profiles.merge!(profiles_hash) do |_, original, added|
        original.merge!(added)
      end

      populate_sourced_data!
    end

    private

    def populate_sourced_data!
      profiles.each do |name, profile|
        sourced = profiles[profile["source_profile"]]
        profile["sourced_data"] = (sourced || {})
      end
    end
  end
end
