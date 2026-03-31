class CatalogEntry < ActiveRecord::Base
  lookup_for :taxonomy_category
end
