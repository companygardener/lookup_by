class IpAddress < ActiveRecord::Base
  lookup_by :ip_address, cache: 2, find_or_create: true
end
