***REMOVED*** == Schema Information
***REMOVED***
***REMOVED*** Table name: memberships
***REMOVED***
***REMOVED***  id         :integer          not null, primary key
***REMOVED***  org_id     :integer
***REMOVED***  user_id    :integer
***REMOVED***  created_at :datetime         not null
***REMOVED***  updated_at :datetime         not null
***REMOVED***

class Membership < ActiveRecord::Base
  belongs_to :org
  belongs_to :user
end
