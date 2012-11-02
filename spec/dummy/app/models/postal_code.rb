class PostalCode < ActiveRecord::Base
  attr_accessible :postal_code

  lookup_by :postal_code, cache: 2
end
