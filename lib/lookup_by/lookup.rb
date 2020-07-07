module LookupBy
  module Lookup
    module MacroMethods
      def is_a_lookup?
        is_a? Lookup::ClassMethods
      end

      def lookup_by_disable(*methods)
        methods.each do |method|
          instance_eval <<-"END", __FILE__, __LINE__ + 1
            def self.#{method}(*args)
              raise NotImplementedError, "#{name}.#{method} is not supported on cached lookup tables." if @lookup.has_cache?

              super
            end
          END
        end
      end

      def lookup_by(field, options = {})
        begin
          return unless table_exists?
        rescue => error
          Rails.logger.error "lookup_by caught #{error.class.name} when connecting - skipping initialization (#{error.inspect})"
          return
        end

        options.symbolize_keys!
        options.assert_valid_keys :allow_blank, :order, :cache, :normalize, :find, :find_or_create, :raise, :safe

        raise "#{self} already called lookup_by" if is_a? Lookup::ClassMethods
        raise "#{self} responds_to .[], needed for lookup_by"     if respond_to? :[]
        raise "#{self} responds_to .lookup, needed for lookup_by" if respond_to? :lookup

        extend ClassMethods

        class_eval do
          include InstanceMethods

          singleton_class.class_eval do
            attr_reader :lookup
          end

          lookup_by_disable :destroy, :destroy_all, :delete, :delete_all

          # TODO: check for a db unique constraint or Rails validation

          unless field == :name || column_names.include?("name")
            alias_attribute :name, field

            attr_accessible :name if respond_to?(:accessible_attributes) && accessible_attributes.include?(field)
          end

          @lookup = Cache.new(self, options.merge(field: field))
          @lookup.load
        end

        LookupBy.register self
      end
    end

    module ClassMethods
      # Rails 4.1, 4.2, 5.0
      def all
        return super if current_scope

        return super if @lookup.read_through?
        return super if @lookup.cache.empty?
        return super if @lookup.disabled?

        relation.tap do |rel|
          rel.instance_variable_set(:@records, @lookup.cache.values)
          rel.instance_variable_set(:@loaded, true)
        end
      end

      if Rails::VERSION::MAJOR <= 4
        # Rails 4.1, 4.2
        def count(column_name = nil, options = {})
          return super if @lookup.read_through?
          return super if column_name

          @lookup.cache.size
        end
      else
        # Rails 5.0
        def count(column_name = nil)
          return super if @lookup.read_through?
          return super if column_name

          @lookup.cache.size
        end
      end

      def pluck(*column_names)
        return super if @lookup.read_through?
        return super if @lookup.disabled?
        return super if column_names.size > 1

        @lookup.cache.values.map { |o| o.send(column_names.first) }
      end

      def [](*args)
        case args.size
        when 0 then raise ArgumentError, "#{name}[*args]: at least one argument is required"
        when 1
          case arg = args.first
          when nil     then nil
          when ""      then @lookup.allow_blank? ? @lookup.fetch(arg) : nil
          when String  then @lookup.fetch(arg)
          when Integer then @lookup.fetch(arg)
          when Symbol  then @lookup.fetch(arg.to_s)
          when IPAddr  then @lookup.fetch(arg.to_s)
          when self    then arg
          else raise TypeError, "#{name}[*args]: args must be at least one String, Symbol, Integer, IPAddr, nil, or #{name}"
          end
        else return args.map { |arg| self[arg] }
        end
      end

      def seed(*args)
        super if defined?(super)

        @lookup.seed *args
        @lookup.reload
      end
    end

    module InstanceMethods
      def ===(arg)
        case arg
        when Symbol, String, Integer, IPAddr, nil
          return self == self.class[arg]
        when Array
          return arg.any? { |i| self === i }
        end

        super
      end
    end

    module SchemaMethods
      # Create a lookup table.
      #
      # @example
      #   create_lookup_table :statuses, schema: "custom", small: true
      #
      #   create_lookup_table :companies do |t|
      #     t.string :short_name
      #   end
      #
      # @param [Symbol] name
      # @param [Hash] options
      # @option options [Symbol] lookup_column Name of the lookup column.
      # @option options [Symbol] lookup_type   Type of the lookup column, _e.g. :text, :uuid, or :inet_.
      # @option options [String] primary_key   Name of the primary key.
      # @option options [String] schema
      def create_lookup_table(name, options = {})
        options.symbolize_keys!

        schema = options[:schema].to_s

        if schema.present?
          table = name.to_s
        else
          schema, table = name.to_s.split('.')
          schema, table = nil, schema unless table
        end

        name = schema.blank? ? table : "#{schema}.#{table}"

        lookup_column = options[:lookup_column] || table.singularize
        lookup_type   = options[:lookup_type]   || :text

        table_options = options.slice(:primary_key, :id)
        table_options[:primary_key] ||= table.singularize + '_id'

        table_options[:id] = false if options[:small]

        create_table name, table_options do |t|
          t.column table_options[:primary_key], 'smallserial primary key' if options[:small]

          t.column lookup_column, lookup_type, null: false

          yield t if block_given?
        end

        add_index name, lookup_column, unique: true, name: "#{table}__u_#{lookup_column}"
      end

      def create_lookup_tables(*names)
        options = names.last.is_a?(Hash) ? names.pop : {}

        names.each do |name|
          create_lookup_table name, options
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
