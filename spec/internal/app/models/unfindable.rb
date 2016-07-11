class Unfindable < ActiveRecord::Base
  lookup_by :unfindable, cache: 10, find: false
end
