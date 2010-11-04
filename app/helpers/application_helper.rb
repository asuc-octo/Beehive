***REMOVED*** Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
	include TagsHelper
  
	module QueryHelpers
		def as_OR_query
			self.gsub " ", " OR "
		end
	end
    
end

class String
	include ApplicationHelper::QueryHelpers
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
        puts "***REMOVED***{n} => ***REMOVED***{n && n!=0}\n"
      n && n!=0
    end
