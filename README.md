
# LookupBy

Cache lookup tables in one line. LookupBy turns <small>`Status["shipped"]`</small> into an in-memory read — 300× faster than a database query, thread-safe, and automatic.

* Look up by any column — not just `name` or `id`
* Automatic caching — read-through, write-through, or LRU
* Symbol-friendly — `order.status == :paid` just works
* Normalized lookups — canonicalize UTF-8, strip whitespace, etc.

### Dependencies

* Rails 7.0+ (_tested on 7.0, 7.1, 7.2, 8.0, 8.1_)
* Ruby 3.1+ (_tested on 3.1, 3.2, 3.3, 3.4, 4.0_)
* PostgreSQL 12+

### Links

* [Source](http://github.com/companygardener/lookup_by)
* [Issues](http://github.com/companygardener/lookup_by/issues)
* [Bug reporting guidelines](https://github.com/companygardener/lookup_by/wiki/Bug-Reports)

_If you find a security bug, **do not** use the public issue tracker. Instead, send an email to: thecompanygardener[removethisifnotspam]@gmail.com._

# Installation

Add this line to your application's Gemfile:

    gem "lookup_by"

And then execute:

    $ bundle

Or install it manually:

    $ gem install lookup_by


# Usage

### ActiveRecord Plugin

LookupBy adds two "macro" methods to `ActiveRecord::Base`

```ruby
class ExampleLookup < ActiveRecord::Base
  lookup_by :column_name
  # Defines .[], .lookup, .is_a_lookup?, and .seed class methods.
end
  
class ExampleObject < ActiveRecord::Base
  lookup_for :status
  # Defines #status and #status= instance methods that transparently reference the lookup table.
  # Defines .with_status(*names) and .without_status(*names) scopes on the model.
end

class Address < ActiveRecord::Base
  # scopes can be renamed
  lookup_for :city, scope: :inside_city, inverse_scope: :outside_city
end
```

### Define the lookup model

```ruby
# db/migrate/201301010012_create_statuses_table.rb
create_table :statuses, primary_key: :status_id do |t|
  t.text :status, null: false
end

# Or use the shorthand
create_lookup_table :statuses

# UUID primary key
#   options[:id]    = :uuid
#
# SMALLSERIAL primary key
#   options[:small] = true
#
# Change the lookup column
#   options[:lookup_column] = "phone_number"
#   options[:lookup_type]   = :phone

# app/models/status.rb
class Status < ActiveRecord::Base
  lookup_by :status
end

# Seed some values
Status.seed *%w[unpaid paid shipped]

# Aliases :name to the lookup attribute
Status.new(name: "paid")
```

### Define an association

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

LookupBy creates methods that use the `status` attribute transparently:

```ruby
order = Order.new(status: "paid")

order.status
=> "paid"

order.status_id
=> 1

# Access the lookup object
order.raw_status
=> #<Status id: 1, status: "paid">

# Access the lookup value before type casting
order.status_before_type_cast
=> "paid"

# Look ma', no strings!
Order.column_names
=> ["order_id", "status_id"]
```

### Querying with lookup values

`where`, `where.not`, and `group` resolve lookup names to foreign keys automatically:

```ruby
# where
Order.where(status: "paid")
Order.where(status: ["paid", "shipped"])

# where.not
Order.where.not(status: "returned")
Order.where.not(status: ["returned", "cancelled"])

# group
Order.group(:status)

# chaining
Order.where(status: "paid").group(:status)
```

Foreign keys and string conditions pass through unchanged:

```ruby
Order.where(status_id: 1)
Order.where("status_id = ?", 1)
```

### Seed the lookup table

```ruby
# Find or create each argument
Status.seed *%w[unpaid paid shipped returned]
```

### Manage lookups globally

```ruby
# Clear all caches
LookupBy.clear

# Disable all
LookupBy.disable

# Enable all, this will reload the caches
LookupBy.enable

# Reload all caches
LookupBy.reload
```

# Configuration

### Symbolize

Casts the attribute to a symbol. Enables the setter to take a symbol.

_Bad idea when the set of lookup values is large. Symbols are never garbage collected._

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

By default, missing lookup values will raise an error.

```ruby
# Raise
#   Default
lookup_for :status

# this will raise a LookupBy::Error
Order.status = "non-existent status"

# Set to nil instead
lookup_for :status, strict: false
```

### Caching

The default is no caching. You can also cache all records or use an LRU.

_Note: caching is **per process**, make sure you think through the implications._

```ruby
# No caching - Queries the database each time
#   Default
lookup_by :column_name

# Cache all
#   Use for a small finite list (e.g. status codes, US states)
#
#   Defaults to no read-through, e.g. options[:find] = false
lookup_by :column_name, cache: true

# Cache N records, evicting the least-recently used (LRU)
#   Use for large sets with uneven distribution (e.g. email domain, city)
#
#   Requires read-through
#     options[:find] = true
lookup_by :column_name, cache: 50
```

### Cache miss

Enable cache read-throughs using the `:find` option.

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

### DB miss

Enable cache write-throughs using the `:find_or_create` option.

_Note: This will only work if the primary key is a sequence and all columns but the lookup column are optional._

```ruby
# Return nil
#   Default
lookup_by :column_name

# Find or create
#   Useful for user-submitted fields that grow over time
#   e.g. user_agents, ip_addresses
lookup_by :column_name, cache: 20, find_or_create: true
```

### Raise on miss

Configure cache misses to raise a `LookupBy::RecordNotFound` error.

```ruby
# Return nil
#   Default
lookup_by :column_name, cache: true

# Raise if not found pre-loaded cache
lookup_by :column_name, cache: true, raise: true

# Raise if not found in DB, either
lookup_by :column_name, cache: true, find: true, raise: true
```

### Normalize values

```ruby
# Normalize
#   Call the attribute's setter
lookup_by :column_name, normalize: true
```

### Allow blank

Can be useful to handle `params` that are not required.

```ruby
# Allow blank
#   Treat "" different than nil
lookup_by :column_name, allow_blank: true
```

### Threadsafety

Disable threadsafety using the `:safe` option.

```ruby
# Default: true
lookup_by :column_name, cache: 10, safe: false
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

# Benchmarks

Measured with `benchmark-ips` on PostgreSQL (Apple M3 Max):

| Mode | Example | Lookups/s | vs. no cache |
|------|---------|----------:|:------------:|
| **Full cache** | `cache: true` | 2.5M | 316× faster |
| **LRU cache** (99% hot) | `cache: 100` | 320K | 40× faster |
| **LRU cache** (95% hot) | `cache: 100` | 132K | 17× faster |
| **LRU cache** (90% hot) | `cache: 100` | 72K | 9× faster |
| **LRU cache** (50% hot) | `cache: 100` | 16K | 2× faster |
| **No cache** | _(default)_ | 7.9K | — |

### Thread safety overhead

Measured with 1–16 threads on the same hardware:

| Threads | LRU ops/s | SafeLRU ops/s | Overhead |
|--------:|----------:|--------------:|---------:|
| 1 | 7.1M | 4.2M | 41% |
| 4 | 7.8M | 4.6M | 41% |
| 8 | 8.8M | 5.2M | 41% |
| 16 | 9.7M | 5.7M | 41% |

| Threads | unsafe ops/s | safe ops/s | Overhead |
|--------:|-------------:|-----------:|---------:|
| 1 | 942K | 719K | 24% |
| 4 | 1.0M | 715K | 29% |
| 8 | 1.1M | 865K | 23% |
| 16 | 1.2M | 919K | 25% |

Run locally:

    rake benchmark
    rake benchmark:threads

# Testing

    bundle install
    appraisal rake

# Contribute

  1. Fork
  2. Create a feature branch `git checkout -b new-hotness`
  3. Commit your changes `git commit -am 'Added some feature'`
  4. Push to the branch `git push origin new-hotness`
  5. Create a Pull Request

A list of authors can be found on the [Contributors](http://github.com/companygardener/lookup_by/graphs/contributors) page.

# License

Copyright © 2014–2026 Erik Peterson

MIT License

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
documentation files (the "Software"), to deal in the Software without restriction, including without limitation the
rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit
persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the
Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS
OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
