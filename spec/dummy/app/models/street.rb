class Street < ActiveRecord::Base
  lookup_by :street, find_or_create: true
end
