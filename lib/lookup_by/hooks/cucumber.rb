module LookupBy
  module Hooks
    module Cucumber
      def reload_cache_for(name)
        name.classify.constantize.lookup.reload
      end
    end
  end
end
