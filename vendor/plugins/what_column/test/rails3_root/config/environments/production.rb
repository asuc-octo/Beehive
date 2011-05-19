Rails3Root::Application.configure do
  ***REMOVED*** Settings specified here will take precedence over those in config/environment.rb

  ***REMOVED*** The production environment is meant for finished, "live" apps.
  ***REMOVED*** Code is not reloaded between requests
  config.cache_classes = true

  ***REMOVED*** Full error reports are disabled and caching is turned on
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  ***REMOVED*** Specifies the header that your server uses for sending files
  config.action_dispatch.x_sendfile_header = "X-Sendfile"

  ***REMOVED*** For nginx:
  ***REMOVED*** config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect'

  ***REMOVED*** If you have no front-end server that supports something like X-Sendfile,
  ***REMOVED*** just comment this out and Rails will serve the files

  ***REMOVED*** See everything in the log (default is :info)
  ***REMOVED*** config.log_level = :debug

  ***REMOVED*** Use a different logger for distributed setups
  ***REMOVED*** config.logger = SyslogLogger.new

  ***REMOVED*** Use a different cache store in production
  ***REMOVED*** config.cache_store = :mem_cache_store

  ***REMOVED*** Disable Rails's static asset server
  ***REMOVED*** In production, Apache or nginx will already do this
  config.serve_static_assets = false

  ***REMOVED*** Enable serving of images, stylesheets, and javascripts from an asset server
  ***REMOVED*** config.action_controller.asset_host = "http://assets.example.com"

  ***REMOVED*** Disable delivery errors, bad email addresses will be ignored
  ***REMOVED*** config.action_mailer.raise_delivery_errors = false

  ***REMOVED*** Enable threaded mode
  ***REMOVED*** config.threadsafe!

  ***REMOVED*** Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  ***REMOVED*** the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true

  ***REMOVED*** Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify
end
