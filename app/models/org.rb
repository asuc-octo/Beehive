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

class Org < ActiveRecord::Base
  has_many :memberships
  has_many :members, :through => :memberships, :source => :user
  has_many :curations
  has_many :jobs, :through => :curations

  ***REMOVED*** overriden so that org_path uses 
  def to_param
    abbr
  end

  def self.from_param(param)
    find_by_abbr!(param)
  end
end
