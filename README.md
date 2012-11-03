# LookupBy

[![Build Status](https://secure.travis-ci.org/companygardener/lookup_by.png)](http://travis-ci.org/companygardener/lookup_by)
[![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/companygardener/lookup_by)

### Description

LookupBy is a thread-safe lookup table cache for ActiveRecord. It
reduces normalization pains.

LookupBy adds two macro methods to ActiveRecord:

`lookup_by :column` &mdash; defines `.[]`, `.lookup`, and `.is_a_lookup?`
methods on the class.

`lookup_for :column` &mdash; defines `column` and `column=` accessors that
transparently reference the lookup table.

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

Please submit issues to this Github project in the [Issues
tab][issues]. _Provide a failing rspec test that works with the
existing test suite_.

Installation
------------

Add this line to your application's Gemfile:

    gem "lookup_by"

And then execute:

    $ bundle

Or install it yourself:

    $ gem install lookup_by

Usage / Configuration
=====================

### Define the lookup model

    class Status < ActiveRecord::Base
      lookup_by :column
    end

    # Aliases the `:column` attribute to `:name`.
    Status.new(name: "paid")

### Associations / Foreign Keys

    class Order < ActiveRecord::Base
      lookup_for :status
    end

Creates accessors to use the `status` attribute transparently:

    order = Order.new(status: "paid")

    order.status
    => "paid"

    order.raw_status
    => <#Status id: 1, status: "paid">

    # Access to the lookup value before type casting
    order.status_before_type_cast
    => "paid"

### Symbolize

Casts the attribute to a symbol. Enables the setter to take a symbol.

_This is a bad idea if the set of lookup values is large. Symbols are
never garbage collected._

    class Order < ActiveRecord::Base
      lookup_for :status, symbolize: true
    end

    order = Order.new(status: "paid")

    order.status
    => :paid

    order.status = :shipped
    => :shipped

### Strict

    # Raise
    #   Default
    lookup_for :status

    # this will raise a LookupBy::Error
    Order.status = "non-existent status"

    # Error
    lookup_for :status, strict: false

### Caching

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

### Configure cache misses

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

### Configure database misses

    # Return nil
    #   Default
    lookup_by :column_name

    # Find or create
    #   Useful for user-submitted fields that grow over time
    #   e.g. user_agents, ip_addresses
    # 
    #   Note: Only works if its attributes are nullable
    lookup_by :column_name, cache: 20, find_or_create: true

Integration
===========

### SimpleForm

    = simple_form_for @order do |f|
      = f.input :status
      = f.input :status, :as => :radio_buttons

### Formtastic

    = semantic_form_for @order do |f|
      = f.input :status
      = f.input :status, :as => :radio

Testing
-------

This plugin uses rspec and pry for testing. Make sure you have them
installed:

    bundle

To run the test suite:

    rake

Giving Back
===========

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
