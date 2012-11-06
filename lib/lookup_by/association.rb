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
        field = field.to_sym

        %W(#{field} raw_#{field} #{field}= #{field}_before_type_cast).map(&:to_sym).each do |method|
          raise Error, "method `#{method}` already exists on #{self.inspect}" if instance_methods.include? method
        end

        options.symbolize_keys!
        options.assert_valid_keys(:class_name, :foreign_key, :symbolize, :strict)

        class_name = options[:class_name] || field
        class_name = class_name.to_s.camelize

        foreign_key = options[:foreign_key] || "#{field}_id"
        foreign_key = foreign_key.to_sym

        strict = options[:strict]
        strict = true if strict.nil?

        if table_exists?
          raise Error, "foreign key `#{foreign_key}` is required on #{self}" unless attribute_names.include?(foreign_key.to_s)
        end

        lookup_field = class_name.constantize.lookup.field

        cast = options[:symbolize] ? ".to_sym" : ""

        lookup_object = "#{class_name}[#{foreign_key}]"

        class << self; attr_reader :lookups; end

        @lookups ||= []
        @lookups << field

        class_eval <<-METHODS
          def raw_#{field}
            #{lookup_object}
          end

          def #{field}
            value = #{lookup_object}
            value ? value.#{lookup_field}#{cast} : nil
          end

          def #{field}_before_type_cast
            value = #{lookup_object}
            value.#{lookup_field}_before_type_cast
          end

          def #{field}=(arg)
            value = case arg
            when "", nil
              nil
            when String, Fixnum
              #{class_name}[arg].try(:id)
            when Symbol
              #{%Q(raise ArgumentError, "#{foreign_key}=(Symbol): use `lookup_for :column, symbolize: true` to allow symbols") unless options[:symbolize]}
              #{class_name}[arg].try(:id)
            when #{class_name}
              raise ArgumentError, "self.#{foreign_key}=(#{class_name}): must be saved" unless arg.id
              arg.id
            else
              raise TypeError, "#{foreign_key}=(arg): arg must be a String, Symbol, Fixnum, nil, or #{class_name}"
            end

            #{%Q(raise LookupBy::Error, "\#{arg.inspect} is not in the <#{class_name}> lookup cache" if arg.present? && value.nil?) if strict}

            self.#{foreign_key} = value
          end
        METHODS
      end
    end
  end
end
