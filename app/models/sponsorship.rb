class Sponsorship < ActiveRecord::Base

  ***REMOVED*** === List of columns ===
  ***REMOVED***   id         : integer 
  ***REMOVED***   faculty_id : integer 
  ***REMOVED***   job_id     : integer 
  ***REMOVED***   created_at : datetime 
  ***REMOVED***   updated_at : datetime 
  ***REMOVED*** =======================

  belongs_to :faculty
  belongs_to :job
end
