class Unsynchronizable < ActiveRecord::Base
  lookup_by :unsynchronizable, cache: 1, find_or_create: true, safe: true
end
