module AWSConfig
  class ConfigEntry
    attr_reader :entries

    def initialize(entries)
      @entries = entries
    end

    def [](key)
      entries[key.to_s] || sourced_entries[key.to_s]
    end

    def []=(key, value)
      entries[key.to_s] = value
    end

    def has_key?(key)
      entries.has_key?(key.to_s)
    end

    def config_hash
      {
        access_key_id:      self["aws_access_key_id"],
        secret_access_key:  self["aws_secret_access_key"],
        region:             self["region"]
      }
    end

    def merge!(other)
      @entries = Parser.from_hash(entries.merge(other.entries))
      self
    end

    def sourced_entries
      entries["sourced_data"] || {}
    end

    def respond_to?(id, include_all = false)
      has_key?(id) || super
    end

    def method_missing(id, *args)
      self[id] || sourced_entries[id] || super
    end
  end
end
