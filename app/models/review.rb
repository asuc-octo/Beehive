class Review < ActiveRecord::Base
    has_and_belongs_to_many :faculties
	
	***REMOVED*** validations
	***REMOVED***validates_presence_of :
	
  
end
