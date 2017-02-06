class ReadThroughRaisin < ActiveRecord::Base
  lookup_by :read_through_raisin, cache: true, find: true, raise: true
end
