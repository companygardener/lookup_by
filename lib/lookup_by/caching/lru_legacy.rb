module LookupBy
  module Caching
    class LRU
      def max_size=(size)
        raise ArgumentError.new(:max_size) if size < 1

        @max_size = size

        if @max_size < @data.length
          @data.keys[0..@max_size-@data.size].each do |key|
            @data.delete(key)
          end
        end
      end

      def []=(key, value)
        @data.delete(key)
        @data[key] = value

        # See: http://bugs.ruby-lang.org/issues/8312
        @data.delete(@data.first[0]) if @data.length > @max_size
      end

      def fetch(key)
        found = true
        value = @data.delete(key) { found = false }

        if found
          @data[key] = value
        elsif block_given?
          value = @data[key] = yield key
          @data.delete(@data.first[0]) if @data.length > @max_size
          value
        else
          raise KeyError, "key not found: %p" % [key]
        end
      end
    end
  end
end
