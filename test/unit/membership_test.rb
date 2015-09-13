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

require 'test_helper'

class MembershipsTest < ActiveSupport::TestCase
  ***REMOVED*** test "the truth" do
  ***REMOVED***   assert true
  ***REMOVED*** end
end
