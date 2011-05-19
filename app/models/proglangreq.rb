class Proglangreq < ActiveRecord::Base

  ***REMOVED*** === List of columns ===
  ***REMOVED***   id          : integer 
  ***REMOVED***   job_id      : integer 
  ***REMOVED***   proglang_id : integer 
  ***REMOVED***   created_at  : datetime 
  ***REMOVED***   updated_at  : datetime 
  ***REMOVED*** =======================

  belongs_to :job
  belongs_to :proglang
end
