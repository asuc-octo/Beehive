ResearchMatch::Application.configure do
  ***REMOVED*** Settings specified here will take precedence over those in config/application.rb

  ***REMOVED*** In the development environment your application's code is reloaded on
  ***REMOVED*** every request.  This slows down response time but is perfect for development
  ***REMOVED*** since you don't have to restart the webserver when you make code changes.
  config.cache_classes = false

  config.eager_load = false

  ***REMOVED*** Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  ***REMOVED*** Show full error reports and disable caching
  config.consider_all_requests_local       = true
  ***REMOVED***config.action_view.debug_rjs             = true
  config.action_controller.perform_caching = false

  ***REMOVED*** Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  ***REMOVED*** Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  ***REMOVED*** Logging
  config.log_level = :info

  ***REMOVED***asset
  config.serve_static_assets = true

  ***REMOVED*** CAS authentication
  CASClient::Frameworks::Rails::Filter.configure(
    :cas_base_url => "https://auth-test.berkeley.edu/cas/"
  )

  ***REMOVED*** ActionMailer
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.perform_deliveries = true
  config.action_mailer.delivery_method = :smtp
end

