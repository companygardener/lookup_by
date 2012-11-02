class IpAddress < ActiveRecord::Base
  attr_accessible :ip_address

  lookup_by :ip_address, cache: 2, find_or_create: true
end
