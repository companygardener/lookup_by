class Uncacheable < ActiveRecord::Base
  lookup_by :uncacheable, cache: true, find_or_create: true
end
