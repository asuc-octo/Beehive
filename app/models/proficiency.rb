***REMOVED*** == Schema Information
***REMOVED***
***REMOVED*** Table name: proficiencies
***REMOVED***
***REMOVED***  id          :integer          not null, primary key
***REMOVED***  proglang_id :integer
***REMOVED***  user_id     :integer
***REMOVED***  created_at  :datetime
***REMOVED***  updated_at  :datetime
***REMOVED***

class Proficiency < ActiveRecord::Base
  belongs_to :proglang
  belongs_to :user
end
