class Review < ActiveRecord::Base

  ***REMOVED*** === List of columns ===
  ***REMOVED***   id         : integer 
  ***REMOVED***   user_id    : integer 
  ***REMOVED***   body       : text 
  ***REMOVED***   rating     : integer 
  ***REMOVED***   created_at : datetime 
  ***REMOVED***   updated_at : datetime 
  ***REMOVED***   faculty_id : integer 
  ***REMOVED*** =======================

    belongs_to :user
	belongs_to :faculty
	
	***REMOVED*** validations
	validates_presence_of :faculty, :body, :rating
	validates_length_of :body, :minimum => 50
	validates_numericality_of :rating
	
	
  
end
