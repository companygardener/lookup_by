module Taxonomy
  class Item < ActiveRecord::Base
    self.table_name = "taxonomy_items"

    lookup_for :category
  end
end
