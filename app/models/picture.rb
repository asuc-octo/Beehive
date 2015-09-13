***REMOVED*** == Schema Information
***REMOVED***
***REMOVED*** Table name: pictures
***REMOVED***
***REMOVED***  id         :integer          not null, primary key
***REMOVED***  url        :string(255)
***REMOVED***  user_id    :integer
***REMOVED***  job_id     :integer
***REMOVED***  created_at :datetime
***REMOVED***  updated_at :datetime
***REMOVED***

class Picture < ActiveRecord::Base
  belongs_to :user
  belongs_to :job
end
