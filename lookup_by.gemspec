# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require "lookup_by/version"

Gem::Specification.new do |gem|
  gem.name           = "lookup_by"
  gem.version        = LookupBy::VERSION

  gem.summary        = %q(A thread-safe lookup table cache for ActiveRecord)
  gem.description    = %q(Use database lookup tables in AR models.)

  gem.authors        = ["Erik Peterson"]
  gem.email          = ["thecompanygardener@gmail.com"]

  gem.homepage       = "https://www.github.com/companygardener/lookup_by"
  gem.license        = "MIT"

  gem.files          = `git ls-files -z`.split("\x0")
  gem.executables    = gem.files.grep(%r{^bin/}) { |f| File.basename(f) }
  gem.test_files     = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency "rails", ">= 4.0.0"

  gem.add_development_dependency "bundler", ">= 1.7.0"
  gem.add_development_dependency "rake"
end
