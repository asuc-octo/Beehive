***REMOVED*** Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
	include TagsHelper 
	
	module NonEmpty
	    def nonempty?
	        not self.nil? and not self.empty?
	    end
	end
	
end

class String
    include ApplicationHelper::NonEmpty
end

class Array
    include ApplicationHelper::NonEmpty
end

class NilClass
    include ApplicationHelper::NonEmpty
end


    ***REMOVED*** Amazing logic that returns correct booleans.
    ***REMOVED***
    ***REMOVED***        n   |  output
    ***REMOVED***      ------+----------
    ***REMOVED***        0   |  false
    ***REMOVED***        1   |  true
    ***REMOVED***      false |  false
    ***REMOVED***      true  |  true
    ***REMOVED***
    def from_binary(n)
***REMOVED***      puts "\n\n***REMOVED***{n} => ***REMOVED***{n && n!=0}\n\n"
      n && n!=0
    end
