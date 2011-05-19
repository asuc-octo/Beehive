class Interest < ActiveRecord::Base

  ***REMOVED*** === List of columns ===
  ***REMOVED***   id          : integer 
  ***REMOVED***   category_id : integer 
  ***REMOVED***   user_id     : integer 
  ***REMOVED***   created_at  : datetime 
  ***REMOVED***   updated_at  : datetime 
  ***REMOVED*** =======================

  belongs_to :category
  belongs_to :user
end
