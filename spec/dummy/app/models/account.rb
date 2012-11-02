class Account < ActiveRecord::Base
  attr_accessible :account

  lookup_by :account, cache: true, find: true
end
