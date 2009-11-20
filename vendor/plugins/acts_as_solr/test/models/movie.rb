***REMOVED*** Table fields for 'movies'
***REMOVED*** - id
***REMOVED*** - name
***REMOVED*** - description

class Movie < ActiveRecord::Base
  acts_as_solr :additional_fields => [:current_time, {:time_on_xml => :date}]
  
  def current_time
    Time.now.to_s
  end
  
  def time_on_xml
    Time.now
  end
  
end