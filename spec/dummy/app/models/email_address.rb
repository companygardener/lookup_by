class EmailAddress < ActiveRecord::Base
  attr_accessible :email_address

  lookup_by :email_address, find_or_create: true
end
