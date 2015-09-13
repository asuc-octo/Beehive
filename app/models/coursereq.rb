***REMOVED*** == Schema Information
***REMOVED***
***REMOVED*** Table name: coursereqs
***REMOVED***
***REMOVED***  id         :integer          not null, primary key
***REMOVED***  course_id  :integer
***REMOVED***  job_id     :integer
***REMOVED***  created_at :datetime
***REMOVED***  updated_at :datetime
***REMOVED***

class Coursereq < ActiveRecord::Base
  belongs_to :course
  belongs_to :job
end
