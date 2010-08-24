***REMOVED*** Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
	module QueryHelpers
		def as_OR_query
			self.gsub " ", " OR "
		end
	end
	
	module Search
	  def smartmatches_for(my) ***REMOVED*** matches for a user
		courses = my.course_list_of_user.gsub ",", " "
		cats = my.category_list_of_user.gsub ",", " "
		pls = my.proglang_list_of_user.gsub ",", " "
		query = "***REMOVED***{cats} ***REMOVED***{courses} ***REMOVED***{pls}"
		***REMOVED***Job.find_by_solr_by_relevance(query)
        find_jobs(query)
	  end

      
	end
end

class String
	include ApplicationHelper::QueryHelpers
end

class ApplicationController
	include ApplicationHelper::Search
end