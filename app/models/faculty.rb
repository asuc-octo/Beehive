class Faculty < ActiveRecord::Base

  ***REMOVED*** === List of columns ===
  ***REMOVED***   id         : integer 
  ***REMOVED***   name       : string 
  ***REMOVED***   email      : string 
  ***REMOVED***   department : string 
  ***REMOVED***   created_at : datetime 
  ***REMOVED***   updated_at : datetime 
  ***REMOVED*** =======================

	has_many :sponsorships
	has_many :jobs, :through => :sponsorships
	has_many :reviews
end
