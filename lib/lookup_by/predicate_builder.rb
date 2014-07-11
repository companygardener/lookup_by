module LookupBy
  module PredicateBuilder
    extend ActiveSupport::Concern

    included do
      instance_eval do
        alias :build_from_hash_without_lookup :build_from_hash
        alias :build_from_hash :build_from_hash_with_lookup
      end
    end

    module ClassMethods
      def build_from_hash_with_lookup(klass, attributes, default_table)
        unless klass.respond_to? :lookups
          return build_from_hash_without_lookup(klass, attributes, default_table)
        end

        attributes = attributes.dup
        lookups    = klass.lookups
        attributes.slice(*lookups.keys).each do |attribute, value|
          next if Hash === value

          attributes.delete(attribute)
          lookup_class, foreign_key = lookups[attribute].values_at(:class, :foreign_key)

          attributes[foreign_key] =
            if Array === value
              value.map { |v| lookup_class[v].id }
            else
              lookup_class[value].id
            end
        end

        build_from_hash_without_lookup(klass, attributes, default_table)
      end
    end
  end
end
