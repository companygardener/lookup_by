class Raisin < ActiveRecord::Base
  lookup_by :raisin, cache: true, raise: true
end
