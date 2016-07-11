require "lookup_by/version"
require "lookup_by/railtie" if defined? Rails

require 'active_support'

module LookupBy
  class Error < StandardError; end

  mattr_accessor :classes
  self.classes = []

  mattr_accessor :mutex
  self.mutex = Mutex.new

  UUID_REGEX    = /\A\h{8}-\h{4}-\h{4}-\h{4}-\h{12}\Z/
  UUID_REGEX_V4 = /\A\h{8}-\h{4}-4\h{3}-[89aAbB]\h{3}-\h{12}\Z/

  autoload :Association, "lookup_by/association"
  autoload :Cache,       "lookup_by/cache"
  autoload :Lookup,      "lookup_by/lookup"
  autoload :IPAddr,      "ipaddr"

  module Caching
    autoload :LRU,       "lookup_by/caching/lru"
    autoload :SafeLRU,   "lookup_by/caching/safe_lru"
  end

  class << self
    def register(klass)
      mutex.synchronize do
        self.classes << klass unless classes.include?(klass)
      end
    end

    def lookups
      classes.map { |klass| klass.lookup }
    end

    def clear
      lookups.each { |lookup| lookup.clear }
    end

    def disable
      lookups.each { |lookup| lookup.disable! }
    end

    def enable
      lookups.each { |lookup| lookup.enable! }
    end

    def reload
      lookups.each { |lookup| lookup.reload }
    end
  end
end

begin
  require "simple_form"
  require "lookup_by/hooks/simple_form"
rescue LoadError
end

begin
  require "formtastic"
  require "lookup_by/hooks/formtastic"
rescue LoadError
end
