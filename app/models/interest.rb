***REMOVED*** == Schema Information
***REMOVED***
***REMOVED*** Table name: interests
***REMOVED***
***REMOVED***  id          :integer          not null, primary key
***REMOVED***  category_id :integer
***REMOVED***  user_id     :integer
***REMOVED***  created_at  :datetime
***REMOVED***  updated_at  :datetime
***REMOVED***

class Interest < ActiveRecord::Base
  belongs_to :category
  belongs_to :user
end
