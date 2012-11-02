module LookupBy
  module Caching
    class SafeLRU < LRU
      def initialize(maxsize = nil)
        @mutex = Mutex.new
        super
      end

      def clear
        @mutex.synchronize { super }
      end

      def [](key)
        @mutex.synchronize { super }
      end

      def []=(key, value)
        @mutex.synchronize { super }
      end

      def merge!(hash)
        @mutex.synchronize { super }
      end

      def delete(key)
        @mutex.synchronize { super }
      end
    end
  end
end
