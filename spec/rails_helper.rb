# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'

require 'logger'
require 'combustion'

Combustion.initialize! :active_record

require 'spec_helper'

if ENV["COVERAGE"]
  require 'simplecov'

  SimpleCov.formatter = SimpleCov::Formatter::HTMLFormatter
  SimpleCov.start
end

require 'pry'
require 'rspec/rails'

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
# require File.expand_path("../support/shared_examples_for_a_lookup.rb", __FILE__)
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }
Dir[Rails.root.join(  "../support/**/*.rb")].each { |f| require f }

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.maintain_test_schema! if ActiveRecord::Migration.respond_to?(:maintain_test_schema!)

RSpec.configure do |config|
  config.use_transactional_fixtures = true

  config.backtrace_exclusion_patterns << %r{vendor/}
  config.backtrace_exclusion_patterns << %r{lib/rspec/rails}

  config.infer_spec_type_from_file_location!
end
