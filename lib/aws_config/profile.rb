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
      else
        nil
      end
    end

    def has_key?(key)
      key = key.to_s
      entries.has_key?(key)
    end

    def respond_to?(id, include_all = false)
      has_key?(id) || super
    end

    def method_missing(id, *args)
      if has_key?(id)
        self[id]
      else
        super
      end
    end
  end
end
