module LookupBy
  module Caching
    class LRU < ::Hash
      attr_reader :lru

      def initialize(maxsize)
        super()

        @maxsize = maxsize
        @lru     = []
      end

      def clear
        @lru.clear

        super
      end

      def [](key)
        return nil unless has_key?(key)
        touch(key)
        super
      end

      def []=(key, value)
        touch(key)
        super
        prune
      end

      def merge(hash)
        dup.merge!(hash)
      end

      def merge!(hash)
        hash.each { |k, v| self[k] = v }
        self
      end

      def delete(key)
        @lru.delete(key)

        super
      end

      def to_h
        {}.merge!(self)
      end

    protected

      def touch(key)
        @lru.delete(key)
        @lru << key
      end

      def prune
        delete(@lru.shift) while size > @maxsize
      end
    end
  end
end
