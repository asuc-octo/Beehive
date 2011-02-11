RAILS_GEM_VERSION = '2.1.2' unless defined? RAILS_GEM_VERSION

require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  config.time_zone = 'UTC'
  config.action_controller.session = {
    :session_key => '_rails_session',
    :secret      => 'e2f5641ab4a3627096a2b6ca8c62cefe53f572906ad6a5fb1c949d183a0'
  }
  config.frameworks -= [:active_record]
end


***REMOVED*** Basic CAS client configuration

require 'casclient'
require 'casclient/frameworks/rails/filter'

CASClient::Frameworks::Rails::Filter.configure(
  :cas_base_url => "https://mzukowski.urbacon.net:6543/cas"
)


***REMOVED*** More complicated configuration

***REMOVED***cas_logger = CASClient::Logger.new(RAILS_ROOT+'/log/cas.log')
***REMOVED***cas_logger.level = Logger::DEBUG
***REMOVED***
***REMOVED***CASClient::Frameworks::Rails::Filter.configure(
***REMOVED***  :cas_base_url  => "https://localhost:7778/",
***REMOVED***  :login_url     => "https://localhost:7778/login",
***REMOVED***  :logout_url    => "https://localhost:7778/logout",
***REMOVED***  :validate_url  => "https://localhost:7778/proxyValidate",
***REMOVED***  :session_username_key => :cas_user,
***REMOVED***  :session_extra_attributes_key => :cas_extra_attributes
***REMOVED***  :logger => cas_logger,
***REMOVED***  :authenticate_on_every_request => true
***REMOVED***)
