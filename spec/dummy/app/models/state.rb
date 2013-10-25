class State < ActiveRecord::Base
  lookup_by :state, cache: true
end
