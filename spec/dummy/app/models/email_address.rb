class EmailAddress < ActiveRecord::Base
  lookup_by :email_address, find_or_create: true
end
