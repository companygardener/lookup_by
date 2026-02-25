class PostalCode < ActiveRecord::Base
  lookup_by :postal_code, cache: 100
end
