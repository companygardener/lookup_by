class Status < ActiveRecord::Base
  attr_accessible :status

  lookup_by :status
end
