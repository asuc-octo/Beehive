***REMOVED*** Be sure to restart your server when you modify this file

***REMOVED*** Specifies gem version of Rails to use when vendor/rails is not present
***REMOVED*** RAILS_GEM_VERSION = '2.3.3' unless defined? RAILS_GEM_VERSION

***REMOVED*** Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

***REMOVED*** Get the SMTP password for ActionMailer
require File.join(File.dirname(__FILE__), 'smtp_pw')

Rails::Initializer.run do |config|
  ***REMOVED*** Settings in config/environments/* take precedence over those specified here.
  ***REMOVED*** Application configuration should go into files in config/initializers
  ***REMOVED*** -- all .rb files in that directory are automatically loaded.

  ***REMOVED*** Add additional load paths for your own custom dirs
  ***REMOVED*** config.load_paths += %W( ***REMOVED***{RAILS_ROOT}/extras )

  ***REMOVED*** Specify gems that this application depends on and have them installed with rake gems:install
  ***REMOVED*** config.gem "bj"
  ***REMOVED*** config.gem "hpricot", :version => '0.6', :source => "http://code.whytheluckystiff.net"
  ***REMOVED*** config.gem "sqlite3-ruby", :lib => "sqlite3"
  ***REMOVED*** config.gem "aws-s3", :lib => "aws/s3"

  ***REMOVED*** Only load the plugins named here, in the order given (default is alphabetical).
  ***REMOVED*** :all can be used as a placeholder for all plugins not explicitly named
  ***REMOVED*** config.plugins = [ :exception_notification, :ssl_requirement, :all ]

  ***REMOVED*** Skip frameworks you're not going to use. To use Rails without a database,
  ***REMOVED*** you must remove the Active Record framework.
  ***REMOVED*** config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  ***REMOVED*** Activate observers that should always be running
  ***REMOVED*** config.active_record.observers = :cacher, :garbage_collector, :forum_observer

  ***REMOVED*** Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
  ***REMOVED*** Run "rake -D time" for a list of tasks for finding time zone names.
  config.time_zone = "Pacific Time (US & Canada)"

  ***REMOVED*** The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
  ***REMOVED*** config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}')]
  ***REMOVED*** config.i18n.default_locale = :de
  config.action_controller.relative_url_root = '/research'
  
  ***REMOVED*** ActionMailer config for Gmail
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {      ***REMOVED*** FIXME please
    :address              => "smtp.gmail.com",
    :port                 => 587,
    :domain               => 'localhost',
    :user_name            => 'ucbresearchmatch@gmail.com',
    :password             => @@smtp_pw,
    :authentication       => 'plain',
    :enable_starttls_auto => true  }


end

***REMOVED*** This is the root url for our app (like localhost:3000/)
***REMOVED*** WITH trailing slash
***REMOVED***
***REMOVED*** DEPRECATED
***REMOVED***
***REMOVED***$rm_root = "http://upe.cs.berkeley.edu/research/"

***REMOVED*** Set up ActionMailer
ActionMailer::Base.default_url_options[:host] = "upe.cs.berkeley.edu"   ***REMOVED*** /research is auto appended
ActionMailer::Base.default_content_type = "text/html"
***REMOVED*** You can 'export ENABLE_ACTION_MAILER=true' or false to turn it on or off specifically.
ActionMailer::Base.delivery_method = (ENV['ENABLE_ACTION_MAILER'].present? && ActiveRecord::ConnectionAdapters::Column.value_to_boolean(ENV['ENABLE_ACTION_MAILER'])) ? :smtp : ({'development' => :test, 'test' => :test, 'production' => :smtp}[RAILS_ENV])
ActionMailer::Base.perform_deliveries = true  
puts "ActionMailer delivery method is ***REMOVED***{ActionMailer::Base.delivery_method.to_s.upcase}"

***REMOVED*** CAS authentication
CASClient::Frameworks::Rails::Filter.configure(
  :cas_base_url => ({'development' => "https://auth-test.berkeley.edu/cas/",
                    'test'        => "https://auth-test.berkeley.edu/cas/",
                    'production'  => "https://auth.berkeley.edu/cas/"}[RAILS_ENV])
  ***REMOVED***:cas_base_url => "https://auth.berkeley.edu/cas/"
)

***REMOVED*** LDAP 
require 'ucb_ldap'
UCB::LDAP.host = ({'development' => 'ldap-test.berkeley.edu', 'test' => 'ldap-test.berkeley.edu', 'production' => 'ldap.berkeley.edu'}[RAILS_ENV])
UCB::LDAP.bind_for_rails()
