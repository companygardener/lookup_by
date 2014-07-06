module LookupBy
  module QueryMethods
    extend ActiveSupport::Concern

    included do
      alias :group_without_lookup :group
      alias :group :group_with_lookup

      alias :rewhere_without_lookup :rewhere
      alias :rewhere :rewhere_with_lookup
    end

    def group_with_lookup(*args)
      unless klass.respond_to? :lookups
        group_without_lookup(*args)
      end

      lookups = klass.lookups.slice(*args)
      group_without_lookup(args.map { |arg|
        arg = arg.to_sym
        lookups.key?(arg) ? lookups[arg][:foreign_key] : arg
      })
    end

    def rewhere_with_lookup(conditions)
      unless klass.respond_to? :lookups
        rewhere_without_lookup(conditions)
      end

      lookups = klass.lookups.slice(*conditions.keys)
      unwhere = conditions.keys.map do |key|
        key = key.to_sym
        lookups.key?(key) ? lookups[key][:foreign_key] : key
      end

      unscope(where: unwhere).where(conditions)
    end
  end
end
