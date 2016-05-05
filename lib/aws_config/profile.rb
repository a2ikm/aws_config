module AWSConfig
  class Profile
    attr_reader :name, :entries

    def initialize(name, entries)
      @name    = name.to_s
      @entries = entries
    end

    def [](key)
      key = key.to_s
      if entries.has_key?(key)
        entries[key]
      elsif source_profile?
        entries["source_profile"][key]
      else
        nil
      end
    end

    def []=(key, value)
      key = key.to_s
      entries[key] = value
    end

    def has_key?(key)
      key = key.to_s
      entries.has_key?(key)
    end

    def source_profile?
      entries.key?("source_profile") && entries["source_profile"].is_a?(Profile)
    end

    def respond_to?(id, include_all = false)
      has_key?(id) || super
    end

    def method_missing(id, *args)
      if has_key?(id)
        self[id]
      elsif source_profile?
        if entries["source_profile"].respond_to?(id)
          entries["source_profile"].send(id, args)
        else
          super
        end
      else
        super
      end
    end

    def config_hash
      {
        access_key_id:      self["aws_access_key_id"],
        secret_access_key:  self["aws_secret_access_key"],
        region:             self["region"]
      }
    end

    # Returns a new profile from the two merged profiles
    def merge(profile)
      merged = entries.dup
      merged.merge! profile.entries
      new name, merged
    end

    def merge!(profile)
      entries.merge! profile.entries
      self
    end
  end
end
