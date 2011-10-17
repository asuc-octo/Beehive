class Department < ActiveRecord::Base

  ***REMOVED*** === List of columns ===
  ***REMOVED***   id         : integer 
  ***REMOVED***   name       : text 
  ***REMOVED***   created_at : datetime 
  ***REMOVED***   updated_at : datetime 
  ***REMOVED*** =======================

  has_many :jobs
  has_many :faculties

  class << self
    ***REMOVED*** Define methods like ".eecs"
    Department.all.each do |d|
      define_method d.name.underscore do
        d
      end rescue nil
    end
  end

end
