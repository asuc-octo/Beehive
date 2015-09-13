***REMOVED*** == Schema Information
***REMOVED***
***REMOVED*** Table name: enrollments
***REMOVED***
***REMOVED***  id         :integer          not null, primary key
***REMOVED***  grade      :string(255)
***REMOVED***  semester   :string(255)
***REMOVED***  course_id  :integer
***REMOVED***  user_id    :integer
***REMOVED***  created_at :datetime
***REMOVED***  updated_at :datetime
***REMOVED***

class Enrollment < ActiveRecord::Base

  belongs_to :course
  belongs_to :user
end
