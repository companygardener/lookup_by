begin
  require 'rubygems'
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

require 'combustion'

Bundler::GemHelper.install_tasks

require "rspec/core/rake_task"
RSpec::Core::RakeTask.new(:spec)

desc 'Start a console'
task :console do
  Combustion.initialize! :active_record

  ARGV.clear

  ActiveRecord::Base.logger = Logger.new(STDOUT)

  require 'pry'
  Pry.start
end

namespace :db do
  desc 'Setup db'
  task :setup do
    Combustion.initialize! :active_record
  end
end

task :default => :spec
