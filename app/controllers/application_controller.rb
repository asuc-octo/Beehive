***REMOVED*** Filters added to this controller apply to all controllers in the application.
***REMOVED*** Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include AuthenticatedSystem
  helper :all ***REMOVED*** include all helpers, all the time
  protect_from_forgery ***REMOVED*** See ActionController::RequestForgeryProtection for details

  ***REMOVED*** Scrub sensitive parameters from your log
  ***REMOVED*** filter_parameter_logging :password
end
