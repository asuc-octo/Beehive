class User < ActiveRecord::Base
  
  class MyError < Exception; end
  
  def name_and_age
    "***REMOVED***{name} and ***REMOVED***{age}"
  end
end
