require 'lookup_by/hooks/cucumber'

World(LookupBy::Hooks::Cucumber)

Given "I reload the cache for $name" do |name|
  reload_cache_for(name)
end
