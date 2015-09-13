***REMOVED*** == Schema Information
***REMOVED***
***REMOVED*** Table name: categories
***REMOVED***
***REMOVED***  id         :integer          not null, primary key
***REMOVED***  name       :string(255)
***REMOVED***  created_at :datetime
***REMOVED***  updated_at :datetime
***REMOVED***

class Category < ActiveRecord::Base

  has_and_belongs_to_many :jobs
  has_many :interests
  has_many :users, :through => :interests
  
end
