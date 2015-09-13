***REMOVED*** == Schema Information
***REMOVED***
***REMOVED*** Table name: sponsorships
***REMOVED***
***REMOVED***  id         :integer          not null, primary key
***REMOVED***  faculty_id :integer
***REMOVED***  job_id     :integer
***REMOVED***  created_at :datetime
***REMOVED***  updated_at :datetime
***REMOVED***

class Sponsorship < ActiveRecord::Base
  belongs_to :faculty
  belongs_to :job
end
