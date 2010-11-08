***REMOVED*** Be sure to restart your server when you modify this file

***REMOVED*** Specifies gem version of Rails to use when vendor/rails is not present
***REMOVED*** RAILS_GEM_VERSION = '2.3.3' unless defined? RAILS_GEM_VERSION

***REMOVED*** Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

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
  
end

  ***REMOVED*** This is the root url for our app (like localhost:3000/)
  ***REMOVED*** WITH trailing slash
  $rm_root = "http://upe.cs.berkeley.edu/research/"
  
  ***REMOVED*** Set up ActionMailer
  ActionMailer::Base.default_url_options[:host] = $rm_root
  ActionMailer::Base.delivery_method = :test ***REMOVED*** Defaults to STMP
