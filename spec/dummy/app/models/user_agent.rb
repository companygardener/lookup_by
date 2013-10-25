class UserAgent < ActiveRecord::Base
  lookup_by :user_agent, cache: 2, find_or_create: true
end
