module LookupBy
  module Lookup
    module MacroMethods
      def is_a_lookup?
        is_a? LookupBy::Lookup::ClassMethods
      end

      def lookup_by(field, options = {})
        options.symbolize_keys!
        options.assert_valid_keys :order, :cache, :normalize, :find, :find_or_create, :raise

        raise "#{self} already uses lookup_by" if is_a? LookupBy::Lookup::ClassMethods
        raise "#{self} responds_to :[], needed for lookup_by"     if respond_to? :[]
        raise "#{self} responds_to :lookup, needed for lookup_by" if respond_to? :lookup

        extend ClassMethods

        class_eval do
          include InstanceMethods

          class << self; attr_reader :lookup; end

          # validates field, presence: true, uniqueness: true

          unless field == :name || column_names.include?("name")
            alias_attribute :name, field

            attr_accessible :name if accessible_attributes.include?(field)
          end

          @lookup = Cache.new(self, options.merge(field: field))
          @lookup.reload
        end
      end
    end

    module ClassMethods
      def all
        return super if @lookup.read_through?

        @lookup.cache.values
      end

      def count(column_name = nil, options = {})
        return super if @lookup.read_through?
        return super if column_name

        @lookup.cache.size
      end

      def pluck(column_name)
        return super if @lookup.read_through?

        @lookup.cache.values.map { |o| o.send(column_name) }
      end

      def [](arg)
        case arg
        when nil, "" then nil
        when String  then @lookup.fetch(arg)
        when Symbol  then @lookup.fetch(arg.to_s)
        when Fixnum  then @lookup.fetch(arg)
        when self    then arg
        else raise TypeError, "#{name}[arg]: arg must be a String, Symbol, Fixnum, nil, or #{name}"
        end
      end
    end

    module InstanceMethods
      def ===(arg)
        case arg
        when Symbol, String, Fixnum, nil
          return self == self.class[arg]
        when Array
          return !!arg.detect { |i| self === i }
        end

        super
      end
    end

    module SchemaMethods
      def create_lookup_table(table_name, options = {})
        lookup_column = options[:lookup_column] || table_name.to_s.singularize
        primary_key   = options[:primary_key]   || table_name.to_s.singularize + "_id"

        create_table table_name, primary_key: primary_key do |t|
          t.text lookup_column, null: false

          yield t if block_given?
        end

        add_index table_name, lookup_column, unique: true
      end

      def create_lookup_tables(*table_names)
        table_names.each do |table_name|
          create_lookup_table table_name
        end
      end
    end

    module CommandRecorderMethods
      def create_lookup_table(*args)
        record(:create_lookup_table, args)
      end

      def invert_create_lookup_table(args)
        [:drop_table, [args.first]]
      end
    end
  end
end
