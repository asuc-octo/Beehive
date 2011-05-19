class Proficiency < ActiveRecord::Base

  ***REMOVED*** === List of columns ===
  ***REMOVED***   id          : integer 
  ***REMOVED***   proglang_id : integer 
  ***REMOVED***   user_id     : integer 
  ***REMOVED***   created_at  : datetime 
  ***REMOVED***   updated_at  : datetime 
  ***REMOVED*** =======================

  belongs_to :proglang
  belongs_to :user
end
