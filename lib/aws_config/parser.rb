require "strscan"
require "aws_config/profile"

module AWSConfig
  class Parser
    attr_accessor :credential_file_mode

    def self.parse(string, credential_file_mode = false)
      from_hash(new.tokenize(string))
    end

    def self.from_hash(hash)
      hash.inject({}) do |memo, (k,v)|
        if v.is_a?(Hash)
          memo[k]=Profile.new(k,v)
        else
          memo[k] = v
        end

        memo
      end
    end

    def tokenize(string)
      tokens = { }
      current_profile = nil
      current_nesting = nil

      string.lines.each do |line|
        comment = line.match(/\s*#.*/)
        blank = line.match(/^\s*$/)
        next if comment || blank

        profile_match = line.match(/\[\s*(profile)?\s*(?<profile>[^\]]+)\s*\]/)
        if profile_match
          current_profile = profile_match[:profile]
          tokens[current_profile] ||= {}
          next
        end

        nest_key_value = line.match(/(?<nest>^\s+)?(?<key>[^\s=#]+)\s*=\s*(?<value>[^\s#]+)/)
        if nest_key_value
          nest, key, value = !!nest_key_value[:nest], nest_key_value[:key], nest_key_value[:value]
          if nest
            fail("Nesting without a parent error") if current_nesting.nil?
            tokens[current_profile][current_nesting][key] = value
          else
            current_nesting = nil
            tokens[current_profile][key] = value
          end
          next
        end

        nesting = line.match(/(?<name>[^\s=#]+)\s*=.*/)
        if nesting
          current_nesting = nesting[:name]
          tokens[current_profile][current_nesting] ||= {}
        end
      end
      tokens
    end
  end
end
