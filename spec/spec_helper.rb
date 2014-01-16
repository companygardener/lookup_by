# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'

if ENV["COVERAGE"]
  require "simplecov"
  require 'coveralls'

  SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
    Coveralls::SimpleCov::Formatter,
    SimpleCov::Formatter::HTMLFormatter,
  ]

  SimpleCov.start
end

begin
  require File.expand_path("../../config/environment", __FILE__)
rescue LoadError
  require File.expand_path("../dummy/config/environment", __FILE__)
end

require 'rspec'
require 'database_cleaner'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("../support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  config.backtrace_exclusion_patterns << /vendor\//
  config.backtrace_exclusion_patterns << /lib\/rspec\/rails/

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end

require 'rubinius_helper' if ENV["DEBUG"] && RUBY_ENGINE == 'rbx'
