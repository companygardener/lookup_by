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
      def lookup_for field, options = {}
        begin
          return unless table_exists?
        rescue => error
          Rails.logger.error "lookup_by caught #{error.class.name} when connecting - skipping initialization (#{error.inspect})"
          return
        end

        options.symbolize_keys!
        options.assert_valid_keys(:class_name, :foreign_key, :symbolize, :strict, :scope)

        field = field.to_sym

        %W(#{field} raw_#{field} #{field}= #{field}_before_type_cast #{field}?).map(&:to_sym).each do |method|
          raise Error, "method `#{method}` already exists on #{self.inspect}" if instance_methods.include? method
        end

        singleton_class.class_eval do
          attr_reader :lookups
        end

        @lookups ||= []
        @lookups << field

        scope_name = "with_#{field}" unless options[:scope] == false

        if scope_name
          single_scope = scope_name
          plural_scope = scope_name.pluralize

          raise Error, "#{single_scope} already exists on #{self}. Use `lookup_for #{field}, scope: false` if you don't want scope :#{single_scope}" if respond_to?(single_scope)
          raise Error, "#{plural_scope} already exists on #{self}. Use `lookup_for #{field}, scope: false` if you don't want scope :#{plural_scope}" if respond_to?(plural_scope)
        end

        class_name = options[:class_name] || field
        class_name = class_name.to_s.camelize

        foreign_key = options[:foreign_key] || "#{field}_id"
        foreign_key = foreign_key.to_sym

        raise Error, "foreign key `#{foreign_key}` is required on #{self}" unless attribute_names.include?(foreign_key.to_s)

        strict = options[:strict]
        strict = true if strict.nil?

        class_eval <<-SCOPES, __FILE__, __LINE__.next if scope_name
          scope :#{scope_name},           ->(name)   { where(#{foreign_key}: #{class_name}[name]) }
          scope :#{scope_name.pluralize}, ->(*names) { where(#{foreign_key}: #{class_name}[*names]) }
        SCOPES

        cast = options[:symbolize] ? ".to_sym" : ""

        lookup_field  = class_name.constantize.lookup.field
        lookup_object = "#{class_name}[#{foreign_key}]"

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
            value = case arg
            when nil
              nil
            when String, Integer, IPAddr
              #{class_name}[arg].try(:id)
            when Symbol
              #{%Q(raise ArgumentError, "#{foreign_key}=(Symbol): use `lookup_for :column, symbolize: true` to allow symbols") unless options[:symbolize]}
              #{class_name}[arg].try(:id)
            when #{class_name}
              raise ArgumentError, "self.#{foreign_key}=(#{class_name}): must be saved" unless arg.id
              arg.id
            else
              raise TypeError, "#{foreign_key}=(arg): arg must be a String, Symbol, Integer, IPAddr, nil, or #{class_name}"
            end

            #{%Q(raise LookupBy::Error, "\#{arg.inspect} is not in the <#{class_name}> lookup cache" if arg.present? && value.nil?) if strict}

            self.#{foreign_key} = value
          end
        METHODS
      end
    end
  end
end
