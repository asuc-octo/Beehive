class Category < ActiveRecord::Base

  ***REMOVED*** === List of columns ===
  ***REMOVED***   id         : integer 
  ***REMOVED***   name       : string 
  ***REMOVED***   created_at : datetime 
  ***REMOVED***   updated_at : datetime 
  ***REMOVED*** =======================

  has_many :jobs, :through => :categories_jobs
  
  has_many :interests
  has_many :users, :through => :interests
  
end
