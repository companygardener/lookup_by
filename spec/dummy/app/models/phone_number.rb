class PhoneNumber < ActiveRecord::Base
  lookup_by :phone_number, find_or_create: true, allow_blank: false

  validates :phone_number, format: /\d{3}-\d{3}-\d{4}/, length: 10..11
end
