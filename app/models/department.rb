***REMOVED*** == Schema Information
***REMOVED***
***REMOVED*** Table name: departments
***REMOVED***
***REMOVED***  id         :integer          not null, primary key
***REMOVED***  name       :text             not null
***REMOVED***  created_at :datetime
***REMOVED***  updated_at :datetime
***REMOVED***

class Department < ActiveRecord::Base

  has_many :jobs
  has_many :faculties

  class << self
    ***REMOVED*** Define methods like ".eecs"
    begin
      Department.all.each do |d|
        define_method d.name.underscore do
          d
        end rescue nil
      end
    rescue => e
    end
  end

end
