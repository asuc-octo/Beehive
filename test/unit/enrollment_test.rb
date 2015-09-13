***REMOVED*** == Schema Information
***REMOVED***
***REMOVED*** Table name: enrollments
***REMOVED***
***REMOVED***  id         :integer          not null, primary key
***REMOVED***  grade      :string(255)
***REMOVED***  semester   :string(255)
***REMOVED***  course_id  :integer
***REMOVED***  user_id    :integer
***REMOVED***  created_at :datetime
***REMOVED***  updated_at :datetime
***REMOVED***

require 'test_helper'

class EnrollmentTest < ActiveSupport::TestCase
  ***REMOVED*** Replace this with your real tests.
  test "the truth" do
    assert true
  end
end
