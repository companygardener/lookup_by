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
      end
    end
  end
end
