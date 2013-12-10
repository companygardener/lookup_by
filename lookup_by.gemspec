# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

require "lookup_by/version"

Gem::Specification.new do |gem|
  gem.name        = "lookup_by"
  gem.version     = LookupBy::VERSION

  gem.summary     = %q(A thread-safe lookup table cache for ActiveRecord)
  gem.description = %q(Use database lookup tables in AR models.)

  gem.authors     = ["Erik Peterson"]
  gem.email       = ["erik@enova.com"]

  gem.homepage    = "http://www.github.com/companygardener/lookup_by"

  gem.executables = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  gem.files       = `git ls-files`.split("\n")
  gem.test_files  = `git ls-files -- {test,spec,features}/*`.split("\n")

  gem.add_dependency "rails", ">= 3.2.0"

  gem.add_development_dependency "bundler", "~> 1.3"
  gem.add_development_dependency "rake"
end
