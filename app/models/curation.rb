***REMOVED*** == Schema Information
***REMOVED***
***REMOVED*** Table name: curations
***REMOVED***
***REMOVED***  id         :integer          not null, primary key
***REMOVED***  job_id     :integer
***REMOVED***  org_id     :integer
***REMOVED***  user_id    :integer
***REMOVED***  created_at :datetime         not null
***REMOVED***  updated_at :datetime         not null
***REMOVED***

class Curation < ActiveRecord::Base

  belongs_to :job
  belongs_to :org
  belongs_to :user
end
