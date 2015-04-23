***REMOVED*** Filters added to this controller apply to all controllers in the application.
***REMOVED*** Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all ***REMOVED*** include all helpers, all the time
  include ApplicationHelper ***REMOVED*** this is still necessary
  include CASControllerIncludes
  protect_from_forgery ***REMOVED*** See ActionController::RequestForgeryProtection for details

  before_filter :set_current_user
  before_filter :set_actionmailer_base_url

  ***REMOVED*** rescue_from Exception do |e|
  ***REMOVED***   @exception = e
  ***REMOVED***   render 'common/exception', :status => 500

  ***REMOVED***   Rails.logger.error "ERROR 500: ***REMOVED***{e.inspect}"

  ***REMOVED***   request.env["exception_notifier.exception_data"] = {
  ***REMOVED***     :timestamp => Time.now.to_i
  ***REMOVED***   }

  ***REMOVED***   begin
  ***REMOVED***     ExceptionNotifier::Notifier.exception_notification(request.env, e).deliver
  ***REMOVED***   rescue => f
  ***REMOVED***     Rails.logger.error "ExceptionNotifier: Failed to deliver because ***REMOVED***{f.inspect}"
  ***REMOVED***   end
  ***REMOVED***   raise if Rails.test?
  ***REMOVED*** end

  ***REMOVED*** Puts a flash[:notice] error message and redirects if condition isn't true.
  ***REMOVED*** Returns true if redirected.
  ***REMOVED***
  ***REMOVED*** Usage: return if redirect_if(!user_logged_in, "Not logged in!", "/diaf")
  ***REMOVED***
  def redirect_if(condition=true, error_msg='Error!', redirect_url=nil)
    false if condition == false or redirect_url.nil?
    flash[:error] = error_msg
    redirect_to redirect_url unless redirect_url.nil?
    true
  end



***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED***     FILTERS      ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***

  ***REMOVED*** Used by both ApplicsController and JobsController
  def job_accessible
    j = (Job.find(params[:job_id].present? ? params[:job_id] : params[:id]) rescue nil)
    if j == nil
      flash[:error] = 'We couldn\'t find that project.'
      redirect_to jobs_path
    end
  end

  ***REMOVED*** User shouldn't watch or apply to their own job.
  def watch_apply_ok_for_job
    j = (Job.find(params[:job_id].present? ? params[:job_id] : params[:id]) rescue nil)
    if j == nil || @current_user == j.user
      flash[:error] = 'You can\'t watch or apply to your own listing.'
      redirect_to job_path(j)
    end
  end

  ***REMOVED*** Tests exception notification by raising an uncaught exception.
  def test_exception_notification
    raise NotImplementedError.new('Exceptions aren\'t implemented yet.')
  end

  private

  def set_actionmailer_base_url
    ActionMailer::Base.default_url_options ||= {}
    ActionMailer::Base.default_url_options[:host] = request.host_with_port
  end

  def set_current_user
    @user_session = UserSession.find
    @current_user = @user_session ? @user_session.user : nil
  end
  
  def require_admin
    unless logged_in_as_admin?
      redirect_to request.referer || home_path, :notice => 'Insufficient privileges'
    end
  end

end
