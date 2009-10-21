***REMOVED*** This controller handles the login/logout function of the site.  
class <%= controller_class_name %>Controller < ApplicationController
  ***REMOVED*** Be sure to include AuthenticationSystem in Application Controller instead
  include AuthenticatedSystem

  ***REMOVED*** render new.rhtml
  def new
  end

  def create
    logout_keeping_session!
    <%= file_name %> = <%= class_name %>.authenticate(params[:login], params[:password])
    if <%= file_name %>
      ***REMOVED*** Protects against session fixation attacks, causes request forgery
      ***REMOVED*** protection if user resubmits an earlier form using back
      ***REMOVED*** button. Uncomment if you understand the tradeoffs.
      ***REMOVED*** reset_session
      self.current_<%= file_name %> = <%= file_name %>
      new_cookie_flag = (params[:remember_me] == "1")
      handle_remember_cookie! new_cookie_flag
      redirect_back_or_default('/')
      flash[:notice] = "Logged in successfully"
    else
      note_failed_signin
      @login       = params[:login]
      @remember_me = params[:remember_me]
      render :action => 'new'
    end
  end

  def destroy
    logout_killing_session!
    flash[:notice] = "You have been logged out."
    redirect_back_or_default('/')
  end

protected
  ***REMOVED*** Track failed login attempts
  def note_failed_signin
    flash[:error] = "Couldn't log you in as '***REMOVED***{params[:login]}'"
    logger.warn "Failed login for '***REMOVED***{params[:login]}' from ***REMOVED***{request.remote_ip} at ***REMOVED***{Time.now.utc}"
  end
end
