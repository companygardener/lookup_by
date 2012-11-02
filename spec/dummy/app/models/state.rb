class State < ActiveRecord::Base
  attr_accessible :state

  lookup_by :state, cache: true
end
