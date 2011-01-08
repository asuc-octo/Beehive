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
    
    ***REMOVED*** Translates \n line breaks to <br />'s.
    def to_br
        self.gsub("\n", "<br />")
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
  def cas_unless_logged_in
    CASClient::Frameworks::Rails::Filter.filter(self) unless logged_in?
  end


  ***REMOVED*** this before_filter takes the results of the rubyCAS-client filter and sets up the current_user, 
  ***REMOVED*** thereby "logging you in" as the proper user in the ResearchMatch database.
  def setup_cas_user
    return unless session[:cas_user].present?
    @current_user = User.find_by_login(session[:cas_user])
    
    ***REMOVED*** if user doesn't exist, create it, and then redirect to edit profile page
    if @current_user.blank?

      ***REMOVED***TODO: Set user metadata [obtained from LDAP] here, including user_type, rather than all 
      ***REMOVED*** this fake garbage data!!
      ***REMOVED***     (note: the login here is correct; the rest is garbage)
***REMOVED***      @person = UCB::LDAP::Person.find_by_uid(session[:cas_user]) 
***REMOVED***      @current_user = User.new(
***REMOVED***                            :login => session[:cas_user].to_s,
***REMOVED***                            :name => "***REMOVED***{@person.firstname} ***REMOVED***{@person.lastname}",
***REMOVED***                            :email => @person.email,
***REMOVED***                            :password => "password", 
***REMOVED***                            :password_confirmation => "password"
***REMOVED***                              ) ***REMOVED*** necessary to pass validations
                          
      ***REMOVED*** This has all been moved to users/new.
           
                              
      ***REMOVED*** @current_user.save!

      ***REMOVED***redirect_to :controller => "users", :action => "edit", :id => @current_user.id
      redirect_to :controller => :users, :action => :new
      return false
    end
    
    @current_user.present?
  end

end

