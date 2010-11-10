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



***REMOVED*** Finds value in find_from, and returns the corresponding item from choose_from,
***REMOVED*** or default (nil) if find_from does not contain the value.
***REMOVED*** Comparisons are done using == and then eql? .
***REMOVED***
***REMOVED*** Ex. find_and_choose(["apples", "oranges"], [:red, :orange], "apples")
***REMOVED***        would return :red.
***REMOVED***
def find_and_choose(find_from=[], choose_from=[], value=nil, default=nil)
    find_from.each_index do |i|
        puts "\n\nchecking ***REMOVED***{value} == ***REMOVED***{find_from[i]}\n"
        return choose_from[i] if find_from[i] == value || find_from[i].eql?(value)
        puts "\n\n\n***REMOVED***{value} wasn't ***REMOVED***{find_from[i]}\n\n\n"
    end
    return default
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
