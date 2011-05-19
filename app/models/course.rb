class Course < ActiveRecord::Base

  ***REMOVED*** === List of columns ===
  ***REMOVED***   id         : integer 
  ***REMOVED***   created_at : datetime 
  ***REMOVED***   updated_at : datetime 
  ***REMOVED***   name       : string 
  ***REMOVED***   desc       : text 
  ***REMOVED*** =======================

  has_many :enrollments
  has_many :users, :through => :enrollments
  has_many :coursereqs
  has_many :jobs, :through => :coursereqs
end
