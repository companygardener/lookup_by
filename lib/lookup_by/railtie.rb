require "active_record/railtie"

module LookupBy
  class Railtie < ::Rails::Railtie
    initializer "lookup_by" do
      ActiveSupport.on_load :active_record do
        extend Lookup::MacroMethods
        extend Association::MacroMethods

        ActiveRecord::ConnectionAdapters::AbstractAdapter.class_eval do
          include Lookup::SchemaMethods
        end

        ActiveRecord::Migration::CommandRecorder.class_eval do
          include Lookup::CommandRecorderMethods
        end

        ActiveRecord::PredicateBuilder.class_eval do
          include LookupBy::PredicateBuilder
        end

        ActiveRecord::Relation.instance_eval do
          include LookupBy::QueryMethods
        end
      end
    end
  end
end
