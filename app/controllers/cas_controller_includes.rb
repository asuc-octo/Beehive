module CASControllerIncludes

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

