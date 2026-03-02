module Taxonomy
  class Category < ActiveRecord::Base
    self.table_name = "taxonomy_categories"

    lookup_by :category
  end
end
