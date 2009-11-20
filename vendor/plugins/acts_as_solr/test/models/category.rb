***REMOVED*** Table fields for 'categories'
***REMOVED*** - id
***REMOVED*** - name

class Category < ActiveRecord::Base
  has_many :books
  acts_as_solr :include => [:books]
end