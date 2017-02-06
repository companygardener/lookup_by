class Account < ActiveRecord::Base
  lookup_by  :account, cache: true, find: true

  lookup_for :phone_number
end
