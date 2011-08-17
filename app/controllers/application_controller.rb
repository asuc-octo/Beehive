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



***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED***     FILTERS      ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***

  def view_ok_for_unactivated_job
    j = Job.find(params[:id].present? ? params[:id] : params[:job_id])
      ***REMOVED*** id and job_id because this filter is used by both the JobsController
      ***REMOVED*** and the ApplicsController
    if (j == nil || ! j.active && @current_user != j.user)
      flash[:error] = "Unauthorized access denied. Do not pass Go. Do not collect $200."
      redirect_to :controller => 'dashboard', :action => :index
    end
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
