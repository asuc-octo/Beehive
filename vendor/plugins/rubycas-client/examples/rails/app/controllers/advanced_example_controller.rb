***REMOVED*** A more advanced example.
***REMOVED*** For basic usage see the SimpleExampleController.
class AdvancedExampleController < ApplicationController
  ***REMOVED*** This will allow the user to view the index page without authentication
  ***REMOVED*** but will process CAS authentication data if the user already
  ***REMOVED*** has an SSO session open.
  before_filter CASClient::Frameworks::Rails::GatewayFilter, :only => :index

  ***REMOVED*** This requires the user to be authenticated for viewing allother pages.
  before_filter CASClient::Frameworks::Rails::Filter, :except => :index

  def index
    @username = session[:cas_user]
    
    @login_url = CASClient::Frameworks::Rails::Filter.login_url(self)
  end

  def my_account
    @username = session[:cas_user]

    ***REMOVED*** Additional user attributes are available if your
    ***REMOVED*** CAS server is configured to provide them.
    ***REMOVED*** See http://code.google.com/p/rubycas-server/wiki/HowToSendExtraUserAttributes
    @extra_attributes = session[:cas_extra_attributes]
  end

  def logout
    CASClient::Frameworks::Rails::Filter.logout(self)
  end

end
