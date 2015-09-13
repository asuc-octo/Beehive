***REMOVED*** == Schema Information
***REMOVED***
***REMOVED*** Table name: faculties
***REMOVED***
***REMOVED***  id            :integer          not null, primary key
***REMOVED***  name          :string(255)      not null
***REMOVED***  email         :string(255)
***REMOVED***  created_at    :datetime
***REMOVED***  updated_at    :datetime
***REMOVED***  department_id :integer
***REMOVED***  calnetuid     :string
***REMOVED***

require 'test_helper'

class FacultyTest < ActiveSupport::TestCase
  ***REMOVED*** Replace this with your real tests.
  test "the truth" do
    assert true
  end
end
