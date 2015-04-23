class Faculty < ActiveRecord::Base

  ***REMOVED*** === List of columns ===
  ***REMOVED***   id            : integer 
  ***REMOVED***   name          : string 
  ***REMOVED***   email         : string 
  ***REMOVED***   created_at    : datetime 
  ***REMOVED***   updated_at    : datetime 
  ***REMOVED***   department_id : integer 
  ***REMOVED***   calnetuid     : string 
  ***REMOVED*** =======================

  default_scope {order('name')}
  
  has_many :sponsorships
  has_many :jobs, :through => :sponsorships
  has_many :reviews
  belongs_to :department

  validates_presence_of :name

  attr_accessible :name, :email, :department_id

end
