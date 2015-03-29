module LookupBy
  module Caching
    class LRU
      # In Ruby 1.9+, Hash is ordered.
      #
      # http://bugs.ruby-lang.org/issues/8312
      # In Ruby 2.0, Hash#shift is bugged and horribly slow.
      #
      #     require 'benchmark/ips'
      #     hash, i, N = {}, 0, 20_000_000; while i < N; hash[i] = true; i += 1; end
      #
      #     Benchmark.ips do |x|
      #       x.report("shift") { hash.shift }
      #       x.report("first") { hash.delete hash.first[0] }
      #     end
      #
      # Ruby       | shift | first
      # -----------+-------+------
      # 1.9.3-p484 |  264k |   89k
      # 1.9.3-p551 |  945k |  370k
      # 2.0.0-p0   |    0k |   70k
      # 2.0.0-p643 |    0k |  272k
      # 2.1.5      | 4947k | 3557k
      # 2.2.1      | 6801k | 4457k
      # rbx-2.5.2  |  609k |  409k

      def initialize(max_size)
        @data = {}
        self.max_size = max_size
      end

      def max_size=(size)
        raise ArgumentError.new(:maxsize) if size < 1

        @max_size = size

        @data.shift while @data.length > @max_size
      end

      def [](key)
        found = true
        value = @data.delete(key) { found = false }

        @data[key] = value if found
      end

      def []=(key, value)
        @data.delete(key)
        @data[key] = value
        @data.shift if @data.length > @max_size
      end

      def clear
        @data.clear
      end

      def count
        @data.length
      end

      def delete(key)
        @data.delete(key)
      end

      def each
        @data.to_a.each do |pair|
          yield pair
        end
      end

      def fetch(key)
        found = true
        value = @data.delete(key) { found = false }

        if found
          @data[key] = value
        elsif block_given?
          value = @data[key] = yield key
          @data.shift if @data.length > @max_size
          value
        else
          raise KeyError, "key not found: %p" % [key]
        end
      end

      def key?(key)
        @data.key?(key)
      end

      def size
        @data.size
      end

      def to_a
        @data.to_a
      end

      def to_h
        @data.dup
      end

      def values
        @data.values
      end
    end
  end
end

if RUBY_ENGINE == "ruby" && RUBY_VERSION == "2.0.0"
  require "lookup_by/caching/lru_legacy"
end
