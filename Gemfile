source "https://rubygems.org"

# Declare your gem's dependencies in lookup_by.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.
gemspec

group :development, :test do
  gem 'appraisal', '~> 2.2.0', require: false

  gem 'combustion'

  gem 'rspec'
  gem 'rspec-its'
  gem 'rspec-rails'

  gem "pg", platform: :ruby
  # gem "activerecord-jdbcpostgresql-adapter", platform: :jruby

  gem "simplecov", "~> 0.18.5", require: false

  gem "pry",       require: false
  gem 'colored',   require: false

  gem 'racc'
  gem 'json'
end
