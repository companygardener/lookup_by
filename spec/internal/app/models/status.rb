class Status < ActiveRecord::Base
  lookup_by :status, normalize: true

  def status=(arg)
    write_attribute :status, arg.strip if arg.respond_to?(:strip)
  end
end
