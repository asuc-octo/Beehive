***REMOVED*** Table fields for 'movies'
***REMOVED*** - id
***REMOVED*** - name
***REMOVED*** - biography

class Author < ActiveRecord::Base

  acts_as_solr :auto_commit => false
  
end