source "https://rubygems.org"

# Declare your gem's dependencies in lookup_by.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.
gemspec

group :development, :test do
  gem 'rspec'
  gem 'database_cleaner'

  gem "pg", platform: :ruby
  gem "activerecord-jdbcpostgresql-adapter", platform: :jruby

  gem "simplecov", require: false
  gem 'coveralls', require: false

  gem "pry",       require: false
  gem 'colored',   require: false

  platform :rbx do
    gem 'racc'
    gem 'json'

    # Simplecov and Coveralls
    gem 'rubysl-coverage'
    gem 'rubinius-coverage'

    # Pry
    gem 'rubysl-readline'

    # Rails
    gem 'rubysl-base64'
    gem 'rubysl-benchmark'
    gem 'rubysl-bigdecimal'
    gem 'rubysl-digest'
    gem 'rubysl-ipaddr'
    gem 'rubysl-logger'
    gem 'rubysl-mutex_m'
    gem 'rubysl-singleton'
  end
end
