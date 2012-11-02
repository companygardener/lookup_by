class Street < ActiveRecord::Base
  attr_accessible :street

  lookup_by :street, find_or_create: true
end
