source "https://rubygems.org"

# Declare your gem's dependencies in lookup_by.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.
gemspec

group :development, :test do
  gem 'appraisal', '~> 1.0', require: false

  gem 'rspec'
  gem 'rspec-its'
  gem 'rspec-rails'
  # gem 'database_cleaner'

  gem "pg", platform: :ruby
  gem "activerecord-jdbcpostgresql-adapter", platform: :jruby

  gem "simplecov", require: false
  gem 'coveralls', require: false

  gem "pry",       require: false
  gem 'colored',   require: false

  gem 'racc'
  gem 'json'
end
