***REMOVED*** Table fields for 'electronics'
***REMOVED*** - id
***REMOVED*** - name
***REMOVED*** - manufacturer
***REMOVED*** - features
***REMOVED*** - category
***REMOVED*** - price
***REMOVED*** - created_on

class Electronic < ActiveRecord::Base
  acts_as_solr :facets => [:category, :manufacturer],
               :fields => [:name, :manufacturer, :features, :category, {:created_at => :date}, {:updated_at => :date}, {:price => {:type => :range_float, :boost => 10.0}}],
               :boost  => 5.0, 
               :exclude_fields => [:features]

  ***REMOVED*** The following example would also convert the :price field type to :range_float
  ***REMOVED*** 
  ***REMOVED*** acts_as_solr :facets => [:category, :manufacturer],
  ***REMOVED***              :fields => [:name, :manufacturer, :features, :category, {:price => :range_float}],
  ***REMOVED***              :boost  => 5.0
end
