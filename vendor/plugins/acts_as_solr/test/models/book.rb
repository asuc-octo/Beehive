***REMOVED*** Table fields for 'books'
***REMOVED*** - id
***REMOVED*** - category_id
***REMOVED*** - name
***REMOVED*** - author

class Book < ActiveRecord::Base
  belongs_to :category
  acts_as_solr :include => [:category]
end