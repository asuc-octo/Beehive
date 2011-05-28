***REMOVED*** Filters added to this controller apply to all controllers in the application.
***REMOVED*** Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all ***REMOVED*** include all helpers, all the time
  protect_from_forgery ***REMOVED*** See ActionController::RequestForgeryProtection for details

  before_filter :set_current_user

  def current_user
    ***REMOVED*** TODO: transition this out in favor of @current_user
    ActiveSupport::Deprecation.warn "current_user is deprecated in favor of @current_user", caller
    @current_user
  end

  ***REMOVED*** Puts a flash[:notice] error message and redirects if condition isn't true.
  ***REMOVED*** Returns true if redirected.
  ***REMOVED***
  ***REMOVED*** Usage: return if redirected_because(!user_logged_in, "Not logged in!", "/diaf")
  ***REMOVED***
  def redirected_because(condition=true, error_msg="Error!", redirect_url=nil)
    return false if condition == false or redirect_url.nil?
    flash[:error] = error_msg
    redirect_to redirect_url unless redirect_url.nil?
    return true
  end

  private

  def set_current_user
    @user_session = UserSession.find
    if @user_session
      @current_user ||= @user_session.user
    else
      @current_user = nil
    end
  end
  
end
