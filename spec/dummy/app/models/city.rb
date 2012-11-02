class City < ActiveRecord::Base
  attr_accessible :city

  lookup_by :city
end
