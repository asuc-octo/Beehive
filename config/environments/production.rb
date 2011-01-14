***REMOVED*** Settings specified here will take precedence over those in config/environment.rb

***REMOVED*** The production environment is meant for finished, "live" apps.
***REMOVED*** Code is not reloaded between requests
config.cache_classes = true

***REMOVED*** Full error reports are disabled and caching is turned on
config.action_controller.consider_all_requests_local = false
config.action_controller.perform_caching             = true
config.action_view.cache_template_loading            = true

***REMOVED*** ActionMailer should actually send mail when using the production server
ActionMailer::Base.delivery_method = :smtp

***REMOVED*** See everything in the log (default is :info)
***REMOVED*** config.log_level = :debug

***REMOVED*** Use a different logger for distributed setups
***REMOVED*** config.logger = SyslogLogger.new

***REMOVED*** Use a different cache store in production
***REMOVED*** config.cache_store = :mem_cache_store

***REMOVED*** Enable serving of images, stylesheets, and javascripts from an asset server
***REMOVED*** config.action_controller.asset_host = "http://assets.example.com"

***REMOVED*** Disable delivery errors, bad email addresses will be ignored
***REMOVED*** config.action_mailer.raise_delivery_errors = false

***REMOVED*** Enable threaded mode
***REMOVED*** config.threadsafe!

