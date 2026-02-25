# TODO: play nicely with belongs_to
# TODO: has_many association
#
# class Decision
#   lookup_for :reasons
# end
#
# Decision.first.reasons
# => ["employment", "income"]
#
# Decision.new.reasons = %w(employment income)

module LookupBy
  module Association
    module MacroMethods
      # @see https://practicingruby.com/articles/closures-are-complicated
      def lookup_for field, options = {}
        begin
          return unless table_exists?
        rescue => error
          Rails.logger.error "lookup_by caught #{error.class.name} when connecting - skipping initialization (#{error.inspect})"
          return
        end

        options.symbolize_keys!
        options.assert_valid_keys(:class_name, :foreign_key, :symbolize, :strict, :scope, :inverse_scope, :belongs_to)

        field = field.to_sym

        %W(#{field} raw_#{field} #{field}= #{field}_before_type_cast #{field}?).map(&:to_sym).each do |method|
          raise Error, "method `#{method}` already exists on #{self.inspect}" if instance_methods.include? method
        end

        singleton_class.class_eval do
          attr_reader :lookups, :lookup_associations
        end

        @lookups ||= []
        @lookups << field

        @lookup_associations ||= {}
        @lookup_associations[field] = { foreign_key: (options[:foreign_key] || "#{field}_id").to_sym, class_name: (options[:class_name] || field).to_s.camelize }

        unless defined?(@lookup_where_prepended)
          @lookup_where_prepended = true
          model = self

          resolve_lookup_hash = ->(hash) {
            resolved = {}

            hash.each do |key, value|
              if (assoc = model.lookup_associations[key])
                klass = assoc[:class_name].constantize
                resolved_value = Array === value ? value.map { |v| klass[v] } : klass[value]
                resolved[assoc[:foreign_key]] = resolved_value
              else
                resolved[key] = value
              end
            end

            resolved
          }

          where_mod = Module.new do
            define_method(:where) do |*args, **kwargs, &block|
              if kwargs.any? && model.lookup_associations
                super(*args, **resolve_lookup_hash.(kwargs), &block)
              else
                super(*args, **kwargs, &block)
              end
            end
          end

          relation_mod = Module.new do
            define_method(:build_where_clause) do |opts, *rest|
              if opts.is_a?(Hash) && model.lookup_associations
                opts = resolve_lookup_hash.(opts)
              end

              super(opts, *rest)
            end

            define_method(:group) do |*args|
              args = args.map do |arg|
                if arg.is_a?(Symbol) && (assoc = model.lookup_associations[arg])
                  assoc[:foreign_key]
                else
                  arg
                end
              end

              super(*args)
            end
          end

          extend where_mod

          relation_class = const_get(:ActiveRecord_Relation) rescue nil
          relation_class&.prepend(where_mod)
          relation_class&.prepend(relation_mod)
        end

        scope_name =
          if options[:scope] == false
            nil
          elsif !options.key?(:scope) || options[:scope] == true
            "with_#{field}"
          else
            options[:scope].to_s
          end

        inverse_scope_name =
          if options[:inverse_scope] == false
            nil
          elsif !options.key?(:inverse_scope) || options[:inverse_scope] == true
            "without_#{field}"
          else
            options[:inverse_scope].to_s
          end

        if scope_name && respond_to?(scope_name)
          raise Error, "#{scope_name} already exists on #{self}."
        end

        if inverse_scope_name && respond_to?(inverse_scope_name)
          raise Error, "#{inverse_scope_name} already exists on #{self}."
        end

        class_name = options[:class_name] || field
        class_name = class_name.to_s.camelize

        begin
          klass = class_name.constantize
        rescue NameError
          raise Error, "uninitialized constant #{class_name}, call lookup_for with `class_name` option if it doesn't match the foreign key"
        end

        raise Error, "class #{class_name} does not use lookup_by" unless klass.respond_to?(:lookup)

        foreign_key = options[:foreign_key] || "#{field}_id"
        foreign_key = foreign_key.to_sym

        Rails.logger.error "foreign key `#{foreign_key}` is required on #{self}" unless attribute_names.include?(foreign_key.to_s)

        belongs = options[:belongs_to] || false

        class_eval <<-BELONGS_TO, __FILE__, __LINE__.next if belongs
          belongs_to :#{field}, class_name: "#{class_name}", foreign_key: :#{foreign_key}, autosave: false, optional: true
        BELONGS_TO

        class_eval <<-SCOPES, __FILE__, __LINE__.next if scope_name
          scope :#{scope_name}, ->(*names) { where(#{foreign_key}: #{class_name}[*names]) }
        SCOPES

        class_eval <<-SCOPES, __FILE__, __LINE__.next if inverse_scope_name
          scope :#{inverse_scope_name}, ->(*names) {
            if names.length != 1
              where('#{foreign_key} NOT IN (?)', #{class_name}[*names])
            else
              where('#{foreign_key} <> ?', #{class_name}[*names])
            end
          }
        SCOPES

        cast = options[:symbolize] ? ".to_sym" : ""

        lookup_field  = klass.lookup.field
        lookup_object = "#{class_name}[#{foreign_key}]"

        strict = options[:strict]
        strict = true if strict.nil?

        class_eval <<-METHODS, __FILE__, __LINE__.next
          def raw_#{field}
            #{lookup_object}
          end

          def #{field}
            value = #{lookup_object}
            value ? value.#{lookup_field}#{cast} : nil
          end

          def #{field}?(name)
            raise ArgumentError, "Invalid #{field} \#{name.inspect}" unless object = #{class_name}[name]
            #{foreign_key} == object.id
          end

          def #{field}_before_type_cast
            #{lookup_object}.#{lookup_field}_before_type_cast
          end

          def #{field}=(arg)
            result = case arg
            when nil
              nil
            when String, Integer, IPAddr
              #{class_name}[arg]
            when Symbol
              #{%Q(raise ArgumentError, "#{foreign_key}=(Symbol): use `lookup_for :column, symbolize: true` to allow symbols") unless options[:symbolize]}
              #{class_name}[arg]
            when #{class_name}
              raise ArgumentError, "self.#{foreign_key}=(#{class_name}): must be saved" unless arg.persisted?
              arg
            else
              raise TypeError, "#{foreign_key}=(arg): arg must be a String, Symbol, Integer, IPAddr, nil, or #{class_name}"
            end

            #{ %Q(raise LookupBy::Error, "\#{arg.inspect} is not in the <#{class_name}> lookup cache" if arg.present? && result.nil?) if strict }

            if result.blank?
              self.#{foreign_key} = nil
            elsif result.persisted?
              self.#{foreign_key} = result.id
            elsif lookup_errors = result.errors[:#{lookup_field}]
              lookup_errors.each do |msg|
                errors.add :#{field}, msg
              end
            end
          end
        METHODS
      end
    end
  end
end
