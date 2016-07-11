class PostalCode < ActiveRecord::Base
  lookup_by :postal_code, cache: 2
end
