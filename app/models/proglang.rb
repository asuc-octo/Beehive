***REMOVED*** == Schema Information
***REMOVED***
***REMOVED*** Table name: proglangs
***REMOVED***
***REMOVED***  id         :integer          not null, primary key
***REMOVED***  name       :string(255)
***REMOVED***  created_at :datetime
***REMOVED***  updated_at :datetime
***REMOVED***

class Proglang < ActiveRecord::Base
  has_many :proglangreqs
  has_many :jobs, :through => :proglangreqs
end
