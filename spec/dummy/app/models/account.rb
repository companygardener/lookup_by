class Account < ActiveRecord::Base
  lookup_by :account, cache: true, find: true
end
