class Address < ActiveRecord::Base
  lookup_for :city, strict: false
  lookup_for :state, symbolize: true
  lookup_for :postal_code
  lookup_for :street
end
