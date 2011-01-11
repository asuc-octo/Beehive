***REMOVED*** This controller handles the login/logout function of the site.  
class SessionsController < ApplicationController
  ***REMOVED*** Be sure to include AuthenticationSystem in Application Controller instead
  include AuthenticatedSystem
  include CASControllerIncludes

  before_filter CASClient::Frameworks::Rails::Filter
  before_filter :require_signed_up, :except => [:new]
  before_filter :set_setjmp, :only => [:new] ***REMOVED*** Remember previous page when logging in
  before_filter :dashboard_if_logged_in, :except => [:destroy]

  protected
  def dashboard_if_logged_in
    redirect_to dashboard_path if logged_in?
  end

  def set_setjmp
    puts "\n\n\n\n\n\nsetjmp = ***REMOVED***{flash[:setjmp]} => "
    flash[:setjmp] = request.referer if flash[:setjmp].blank?
    puts "***REMOVED***{flash[:setjmp]}\n\n\n\n\n\n"
  end

  public

  ***REMOVED*** Don't render new.rhtml; instead, just redirect to dashboard, because  
  ***REMOVED*** we want to prevent people from accessing restful_authentication's 
  ***REMOVED*** user subsystem directly, instead using CAS.
  def new
     create
***REMOVED***    logout_keeping_session!
***REMOVED***    respond_to do |format|
***REMOVED***      format.html
***REMOVED***    end
  end

  def create
    ***REMOVED*** We should have a registered User at this point, due to the before_filter.
    logout_keeping_session!
    self.current_user = User.authenticate_by_login(session[:cas_user].to_s)
    if current_user.present?
      handle_remember_cookie! if params[:remember_me].eql?('1')
      flash[:notice] = 'Logged in successfully'
      redirect_to (flash[:setjmp] || dashboard_path)
      flash[:setjmp] = nil
    else ***REMOVED*** No User found
      flash[:error] = "There was a problem logging you in. Try again, <del>eat</del> clear your cookies, and if you still can't log in, please contact support."
      redirect_to login_path
    end
  end

  def destroy
    logout_killing_session!
    session[:cas_user] = nil
    
     ***REMOVED*** http://wiki.case.edu/Central_Authentication_Service: best practices: only logout app, not CAS

    flash[:notice] = "You have been logged out of ResearchMatch. If you'd like to log out of CAS completely, click <a class='caslogout' href='***REMOVED***{url_for :action=>:logout_cas}'>here</a>."
***REMOVED***    redirect_back_or_default(:controller=>"dashboard", :action=>:index) 
    ***REMOVED***redirect_to :controller=>:dashboard, :action=>:index
    redirect_to '/'
  end

  def logout_cas
    CASClient::Frameworks::Rails::Filter.logout(self, url_for(:controller=>:dashboard, :action=>:index) )
  end

protected
  ***REMOVED*** Track failed login attempts
  def note_failed_signin
    flash[:error] = "Couldn't log you in as '***REMOVED***{params[:email]}'. Check your email or password."
    logger.warn "Failed login for '***REMOVED***{params[:email]}' from ***REMOVED***{request.remote_ip} at ***REMOVED***{Time.now.utc}"
  end
end
