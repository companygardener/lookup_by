module LookupBy
  class Cache
    attr_reader   :cache, :field, :stats
    attr_accessor :testing

    def initialize(klass, options = {})
      @klass       = klass
      @primary_key = klass.primary_key
      @field       = options[:field].to_sym
      @cache       = {}
      @order       = options[:order] || @field
      @read        = options[:find]
      @write       = options[:find_or_create]
      @normalize   = options[:normalize]
      @testing     = false
      @enabled     = true

      @stats       = { db: Hash.new(0), cache: Hash.new(0) }

      raise ArgumentError, %Q(unknown attribute "#{@field}" for <#{klass}>) unless klass.column_names.include?(@field.to_s)

      case options[:cache]
      when true
        @type    = :all
        @read  ||= false
      when ::Fixnum
        raise ArgumentError, "`#{@klass}.lookup_by :#{@field}` options[:find] must be true when caching N" if @read == false

        @type    = :lru
        @limit   = options[:cache]
        @cache   = Rails.configuration.allow_concurrency ? Caching::SafeLRU.new(@limit) : Caching::LRU.new(@limit)
        @read    = true
        @write ||= false
        @testing = true if Rails.env.test? && @write
      else
        @read    = true
      end
    end

    def reload
      return unless @type == :all

      clear

      ::ActiveRecord::Base.connection.send :log, "", "#{@klass.name} Load Cache All" do
        @klass.order(@order).each do |i|
          @cache[i.id] = i
        end
      end
    end

    def clear
      @cache.clear
    end

    def create!(*args, &block)
      created = @klass.create!(*args, &block)
      @cache[created.id] = created if cache?
      created
    end

    def fetch(value)
      increment :cache, :get

      value = normalize(value)      if @normalize && !value.is_a?(Fixnum)

      found = cache_read(value) if cache?
      found ||= db_read(value)  if @read
      found ||= db_read(value)  if not @enabled

      @cache[found.id] = found  if found && cache?

      found ||= db_write(value) if @write

      found
    end

    def has_cache?
      @type && @enabled
    end

    def read_through?
      @read
    end

    def enabled?
      @enabled
    end

    def disabled?
      !@enabled
    end

    def enable!
      @enabled = true
      reload
    end

    def disable!
      @enabled = false
      clear
    end

  private

    def normalize(value)
      @klass.new(@field => value).send(@field)
    end

    def cache_read(value)
      if value.is_a? Fixnum
        found = @cache[value]
      else
        found = @cache.values.detect { |o| o.send(@field) == value }
      end

      increment :cache, found ? :hit : :miss

      found
    end

    def db_read(value)
      increment :db, :get

      found = @klass.where(column_for(value) => value).first

      increment :db, found ? :hit : :miss

      found
    end

    # TODO: Handle race condition on create! failure
    def db_write(value)
      column = column_for(value)

      found = @klass.create!(column => value) if column != @primary_key
      found
    end

    def column_for(value)
      value.is_a?(Fixnum) ? @primary_key : @field
    end

    def cache?
      @type && @enabled && !@testing
    end

    def increment(type, stat)
      @stats[type][stat] += 1
    end
  end
end
