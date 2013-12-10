source "http://rubygems.org"

# Declare your gem's dependencies in lookup_by.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.
gemspec

group :development, :test do
  gem "pry"
  gem "rake"
  gem "simplecov", require: false
  gem 'coveralls', require: false
  gem "rspec-rails"
  gem 'database_cleaner'

  gem "pg", platform: :ruby
  gem "activerecord-jdbcpostgresql-adapter", platform: :jruby

  platform :rbx do
    gem 'racc'
    gem 'rubinius-coverage'

    gem 'rubysl'
    gem 'rubysl-test-unit', require: false
  end
end
