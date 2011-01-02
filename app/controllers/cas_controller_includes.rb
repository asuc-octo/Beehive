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
      @current_user = User.new(
                            :login => session[:cas_user].to_s,
                            :name => "CalNet User",
                            :email => "fakeemailaddress" + rand.to_s[2..16] + "@herpderp" + rand.to_s[2..16] + ".berkeley.edu", 
                            :password => "password", 
                            :password_confirmation => "password"
                              ) ***REMOVED*** necessary to pass validations
                              
           
                              
      @current_user.save!

      ***REMOVED***redirect_to :controller => "users", :action => "edit", :id => @current_user.id
    end
    
    @current_user.present?
  end

end

