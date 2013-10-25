class Path < ActiveRecord::Base
  self.table_name = 'traffic.paths'

  lookup_by :path, cache: 40, find_or_create: true
end
