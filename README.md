# LookupBy

[![Build Status](https://secure.travis-ci.org/companygardener/lookup_by.png)](http://travis-ci.org/companygardener/lookup_by)
[![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/companygardener/lookup_by)

### Description

LookupBy is a thread-safe lookup table cache for ActiveRecord that reduces normalization pains.

### Features

* Thread-safety
* Configurable lookup column
* Caching (read-through, write-through, Least Recently Used (LRU))

### Compatibility

* PostgreSQL

### Development

* [github.com/companygardener/lookup_by][development]

### Source

* git clone git://github.com/companygardener/lookup_by.git

### Issues

Please submit issues to this Github project in the [Issues tab][issues]. _Provide a failing rspec test that works with the existing test suite_.

## Installation

```
# in Gemfile
gem "lookup_by"

$ bundle
```

Or install it manually:

    $ gem install lookup_by

# Usage / Configuration

### ActiveRecord Plugin

LookupBy adds 2 macro methods to `ActiveRecord::Base`

```ruby
lookup_by :column_name
# Defines .[], .lookup, and .is_a_lookup? class methods.

lookup_for :column_name
# Defines #column_name and #column_name= accessors that transparently reference the lookup table.
```

### Define the lookup model

```ruby
# db/migrate/201301010012_create_statuses_table.rb
create_table :statuses do |t|
  t.string :status, null: false
end

# app/models/status.rb
class Status < ActiveRecord::Base
  lookup_by :status # Replace :status with the name of your lookup column
end

# Aliases the lookup attribute to :name.
Status.new(name: "paid")
```

### Associations / Foreign Keys

```ruby
# db/migrate/201301010123_create_orders_table.rb
create_table :orders do |t|
  t.belongs_to :status
end

# app/models/order.rb
class Order < ActiveRecord::Base
  lookup_for :status
end
```

Creates accessors to use the `status` attribute transparently:

```ruby
order = Order.new(status: "paid")

order.status
=> "paid"

# Access the lookup object
order.raw_status
=> <#Status id: 1, status: "paid">

# Access the lookup value before type casting
order.status_before_type_cast
=> "paid"
```

### Symbolize

Casts the attribute to a symbol. Enables the setter to take a symbol.

_This is a bad idea if the set of lookup values is large. Symbols are
never garbage collected._

```ruby
class Order < ActiveRecord::Base
  lookup_for :status, symbolize: true
end

order = Order.new(status: "paid")

order.status
=> :paid

order.status = :shipped
=> :shipped
```

### Strict

Do you want missing lookup values to raise an error?

```ruby
# Raise
#   Default
lookup_for :status

# this will raise a LookupBy::Error
Order.status = "non-existent status"

# Set to nil
lookup_for :status, strict: false
```

### Caching

```ruby
# No caching - Not very useful
#   Default
lookup_by :column_name

# Cache all
#   Use for a small finite list (e.g. status codes, US states)
#
#   find: false DEFAULT
lookup_by :column_name, cache: true

# Cache N (with LRU eviction)
#   Use for a large list with uneven distribution (e.g. email domain, city)
#
#   find: true DEFAULT and REQUIRED
lookup_by :column_name, cache: 50
```

### Configure cache misses

```ruby
# Return nil
#   Default when caching all records
#
#   Skips the database for these methods:
#     .all, .count, .pluck
lookup_by :column_name, cache: true

# Find (read-through)
#   Required when caching N records
lookup_by :column_name, cache: 10
lookup_by :column_name, cache: true, find: true
```

### Configure database misses

```ruby
# Return nil
#   Default
lookup_by :column_name

# Find or create
#   Useful for user-submitted fields that grow over time
#   e.g. user_agents, ip_addresses
# 
#   Note: Only works if attributes are nullable
lookup_by :column_name, cache: 20, find_or_create: true
```

### Normalizing values

```ruby
# Normalize
#   Run through the your attribute's setter
lookup_by :column_name, normalize: true
```

# Integration

### Cucumber

```ruby
# features/support/env.rb
require 'lookup_by/cucumber'
```

This provides: `Given I reload the cache for $plural_class_name`

### SimpleForm

```haml
= simple_form_for @order do |f|
  = f.input :status
  = f.input :status, :as => :radio_buttons
```

### Formtastic

```haml
= semantic_form_for @order do |f|
  = f.input :status
  = f.input :status, :as => :radio
```

## Testing

This plugin uses rspec and pry for testing. Make sure you have them installed:

    bundle

To run the test suite:

    rake

# Giving Back

### Contributing

1. Fork
2. Create a feature branch `git checkout -b new-hotness`
3. Commit your changes `git commit -am 'Added some feature'`
4. Push to the branch `git push origin new-hotness`
5. Create a Pull Request

### Attribution

A list of authors can be found on the [LookupBy Contributors page][contributors].

Copyright © 2012 Erik Peterson, Enova

Released under the MIT License. See [MIT-LICENSE][license] file for more details.

[development]: http://www.github.com/companygardener/lookup_by "LookupBy Development"
[issues]: http://www.github.com/companygardener/lookup_by/issues "LookupBy Issues"
[license]: http://www.github.com/companygardener/lookup_by/blob/master/MIT-LICENSE "LookupBy License"
[contributors]: http://github.com/companygardener/lookup_by/graphs/contributors "LookupBy Contributors"
