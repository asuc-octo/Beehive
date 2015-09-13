***REMOVED*** == Schema Information
***REMOVED***
***REMOVED*** Table name: faculties
***REMOVED***
***REMOVED***  id            :integer          not null, primary key
***REMOVED***  name          :string(255)      not null
***REMOVED***  email         :string(255)
***REMOVED***  created_at    :datetime
***REMOVED***  updated_at    :datetime
***REMOVED***  department_id :integer
***REMOVED***  calnetuid     :string
***REMOVED***

class Faculty < ActiveRecord::Base

  default_scope {order('name')}
  has_many :sponsorships
  has_many :jobs, :through => :sponsorships
  has_many :reviews
  belongs_to :department

  validates_presence_of :name
end
