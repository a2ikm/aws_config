require "strscan"
require "aws_config/profile"

module AWSConfig
  class Parser
    def self.parse(string)
      new.parse(string)
    end

    def parse(string)
      wrap(build(tokenize(string)))
    end

    private
      
      def tokenize(string)
        s = StringScanner.new(string)
        tokens  = []

        until s.eos?
          if s.scan(/\[\s*([^\]]+)\s*\]/)
            if s[1] == "default"
              tokens << [:profile, "default"]
            elsif m = s[1].match(/profile\s+([^\s]+)$/)
              tokens << [:profile, m[1]]
            end
          elsif s.scan(/([^\s=#]+)\s*=\s*([^\s#]+)/)
            tokens << [:key_value, s[1], s[2]]
          elsif s.scan(/#[^\n]*/)
          elsif s.scan(/\s+/)
          elsif s.scan(/\n+/)
          else
            s.scan(/./)
            raise "Invalid token `#{s[0]}` as #{s.pos}"
          end
        end

        tokens
      end

      def build(tokens)
        tokens = tokens.dup
        profiles = {}
        profile = nil

        while values = tokens.shift
          head = values.shift

          case head
          when :profile
            profile = profiles[values[0]] ||= {}
          when :key_value
            if profile
              profile[values[0]] = values[1]
            end
          end
        end

        profiles
      end

      def wrap(profiles)
        profiles.inject({}) do |s, (name, properties)|
          s[name] = Profile.new(name, properties)
          s
        end
      end
  end
end
