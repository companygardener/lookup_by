module LookupBy
  module Caching
    class LRU
      attr_reader :lru

      def initialize(maxsize)
        @maxsize = maxsize
        @lru     = []
        @hash    = {}
      end

      def [](key)
        return nil unless @hash.key?(key)
        touch(key)
        @hash[key]
      end

      def []=(key, value)
        touch(key)
        @hash[key] = value
        @hash.delete(@lru.shift) while @hash.size > @maxsize
      end

      def delete(key)
        @lru.delete(key)

        @hash.delete(key)
      end

      def clear
        @lru.clear
        @hash.clear
        self
      end

      def values
        @hash.values
      end

      def size
        @hash.size
      end

      def to_h
        @hash.dup
      end

    private
      def touch(key)
        # TODO: LRU deletes are O(N)
        @lru.delete(key)
        @lru << key
      end
    end
  end
end
