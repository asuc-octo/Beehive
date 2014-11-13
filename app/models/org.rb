class Org < ActiveRecord::Base

  ***REMOVED*** === List of columns ===
  ***REMOVED***   id         : integer 
  ***REMOVED***   name       : string 
  ***REMOVED***   desc       : text 
  ***REMOVED***   created_at : datetime 
  ***REMOVED***   updated_at : datetime 
  ***REMOVED*** =======================

  attr_accessible :desc, :name
  has_many :members, :through => :memberships, :source => :user
  has_many :jobs, :through => :curations
end
