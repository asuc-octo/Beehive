class Enrollment < ActiveRecord::Base

  ***REMOVED*** === List of columns ===
  ***REMOVED***   id         : integer 
  ***REMOVED***   grade      : string 
  ***REMOVED***   semester   : string 
  ***REMOVED***   course_id  : integer 
  ***REMOVED***   user_id    : integer 
  ***REMOVED***   created_at : datetime 
  ***REMOVED***   updated_at : datetime 
  ***REMOVED*** =======================

  belongs_to :course
  belongs_to :user
end
