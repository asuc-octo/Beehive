***REMOVED*** == Schema Information
***REMOVED***
***REMOVED*** Table name: orgs
***REMOVED***
***REMOVED***  id         :integer          not null, primary key
***REMOVED***  name       :string(255)
***REMOVED***  desc       :text
***REMOVED***  created_at :datetime         not null
***REMOVED***  updated_at :datetime         not null
***REMOVED***  abbr       :string(255)
***REMOVED***

require 'test_helper'

class OrgTest < ActiveSupport::TestCase
  ***REMOVED*** test "the truth" do
  ***REMOVED***   assert true
  ***REMOVED*** end
end
