***REMOVED*** This controller handles the login/logout function of the site.  
class SessionsController < ApplicationController
  ***REMOVED*** Be sure to include AuthenticationSystem in Application Controller instead
  include AuthenticatedSystem

  ***REMOVED*** render new.rhtml
  def new
  end

  def create
    logout_keeping_session!
    user = User.authenticate(params[:email], params[:password])
    if user
      ***REMOVED*** Protects against session fixation attacks, causes request forgery
      ***REMOVED*** protection if user resubmits an earlier form using back
      ***REMOVED*** button. Uncomment if you understand the tradeoffs.
      ***REMOVED*** reset_session
      self.current_user = user
      new_cookie_flag = (params[:remember_me] == "1")
      handle_remember_cookie! new_cookie_flag
      redirect_back_or_default(:controller=>"dashboard", :action=>:index)
      flash[:notice] = "Logged in successfully"
    else
      note_failed_signin
      @email       = params[:email]
      @remember_me = params[:remember_me]
      render :action => 'new'
    end
  end

  def destroy
    logout_killing_session!
    flash[:notice] = "You have been logged out."
    redirect_back_or_default(:controller=>"dashboard", :action=>:index) 
  end

protected
  ***REMOVED*** Track failed login attempts
  def note_failed_signin
    flash[:error] = "Couldn't log you in as '***REMOVED***{params[:email]}'. Check your email or password."
    logger.warn "Failed login for '***REMOVED***{params[:email]}' from ***REMOVED***{request.remote_ip} at ***REMOVED***{Time.now.utc}"
  end
end
