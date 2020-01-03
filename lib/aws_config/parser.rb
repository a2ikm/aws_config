require "aws_config/config_entry"

module AWSConfig
  class Parser
    PROFILE_MATCH = /\[\s*(profile)?\s*(?<profile>[^\]]+)\s*\]/
    KEY_VALUE_MATCH = /^(?<key>[^\s=#]+)\s*=\s*(?<value>[^\s#]+)/
    NESTED_KEY_VALUE_MATCH = /^(?<nesting>\s+)(?<key>[^\s=#]+)\s*=\s*(?<value>[^\s#]+)/
    OPEN_NESTING_MATCH = /(?<name>[^\s=#]+)\s*=.*/

    def self.parse(string)
      from_hash(new.tokenize(string))
    end

    def self.from_hash(hash)
      hash.inject({}) do |memo, (k,v)|
        v = ConfigEntry.new(v) if v.is_a?(Hash)
        memo[k] = v
        memo
      end
    end

    def tokenize(string)
      current_profile = nil
      current_nesting = nil

      string.lines.inject({}) do |tokens, line|
        case line
        when PROFILE_MATCH
          current_profile = $~[:profile]
          tokens[current_profile] ||= {}
        when KEY_VALUE_MATCH
          current_nesting, key, value = nil, $~[:key], $~[:value]
          tokens[current_profile][key] = value
        when NESTED_KEY_VALUE_MATCH
          fail("Nesting without a parent error") if current_nesting.nil?
          key, value = $~[:key], $~[:value]
          tokens[current_profile][current_nesting][key] = value
        when OPEN_NESTING_MATCH
          current_nesting = $~[:name]
          tokens[current_profile][current_nesting] ||= {}
        end
        tokens
      end
    end
  end
end
