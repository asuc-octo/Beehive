***REMOVED*** == Schema Information
***REMOVED***
***REMOVED*** Table name: proglangreqs
***REMOVED***
***REMOVED***  id          :integer          not null, primary key
***REMOVED***  job_id      :integer
***REMOVED***  proglang_id :integer
***REMOVED***  created_at  :datetime
***REMOVED***  updated_at  :datetime
***REMOVED***

class Proglangreq < ActiveRecord::Base
  belongs_to :job
  belongs_to :proglang
end
