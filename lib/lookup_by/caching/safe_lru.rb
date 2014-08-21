# TODO: Evaluate using ThreadSafe::Hash and ThreadSafe::Array.

require "mutex_m"

module LookupBy
  module Caching
    class SafeLRU < LRU
      include Mutex_m

      def initialize(maxsize = nil)
        super
      end

      def [](key)
        synchronize { super }
      end

      def []=(key, value)
        synchronize { super }
      end

      def delete(key)
        synchronize { super }
      end

      def clear
        synchronize { super }
      end

      def values
        synchronize { super }
      end

      def size
        synchronize { super }
      end

      def to_h
        synchronize { super }
      end
    end
  end
end
