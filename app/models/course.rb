***REMOVED*** == Schema Information
***REMOVED***
***REMOVED*** Table name: courses
***REMOVED***
***REMOVED***  id         :integer          not null, primary key
***REMOVED***  created_at :datetime
***REMOVED***  updated_at :datetime
***REMOVED***  name       :string(255)
***REMOVED***  desc       :text
***REMOVED***

class Course < ActiveRecord::Base

  has_many :enrollments
  has_many :users, :through => :enrollments
  has_many :coursereqs
  has_many :jobs, :through => :coursereqs
end
