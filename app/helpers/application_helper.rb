***REMOVED*** Methods added to this helper will be available to all templates in the application.
include JobsHelper


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
    
    ***REMOVED*** Translates \n line breaks to <br />'s.
    def to_br
        self.gsub("\n", "<br />")
    end

    def pluralize_for(n=1)
      n == 1 ? self : self.pluralize
    end
    
end

class Array
    include ApplicationHelper::NonEmpty
end

class NilClass
    include ApplicationHelper::NonEmpty
end

class Time
    def pp
        self.getlocal.strftime("%b %d, %Y")
    end
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



module CASControllerIncludes
  def goto_cas_unless_logged_in
    CASClient::Frameworks::Rails::Filter.filter(self) unless logged_in?
  end

  def rm_login_required
    flash[:setjmp] = request.url
    login_required
  end

  ***REMOVED*** Redirects to signup page if user hasn't registered.
  ***REMOVED*** Filter fails if no CAS session is present, or if user was redirected to
  ***REMOVED*** signup page.
  ***REMOVED*** Filter passes if CAS session is present, and a user exists.
  def require_signed_up
    return true if session[:cas_user].present? and User.exists?(:login => session[:cas_user])

    redirect_to :controller => :users, :action => :new
    return false
  end

end

