class Picture < ActiveRecord::Base

  ***REMOVED*** === List of columns ===
  ***REMOVED***   id         : integer 
  ***REMOVED***   url        : string 
  ***REMOVED***   user_id    : integer 
  ***REMOVED***   job_id     : integer 
  ***REMOVED***   created_at : datetime 
  ***REMOVED***   updated_at : datetime 
  ***REMOVED*** =======================

  belongs_to :user
  belongs_to :job
end
