require "lookup_by/version"
require "lookup_by/railtie" if defined? Rails

module LookupBy
  class Error < StandardError; end

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
