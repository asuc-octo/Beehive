class Review < ActiveRecord::Base
    belongs_to :user
	belongs_to :faculty
	
	***REMOVED*** validations
	***REMOVED***validates_presence_of :
	
  
end
