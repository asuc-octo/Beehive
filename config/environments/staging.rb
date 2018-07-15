ResearchMatch::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # The production environment is meant for finished, "live" apps.
  # Code is not reloaded between requests
  config.cache_classes = true

  config.eager_load = true

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = false

  # Disable full error reports and enable caching
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify

  # CAS authentication
  CASClient::Frameworks::Rails::Filter.configure(
    :cas_base_url => "https://auth.berkeley.edu/cas/"
  )

  # Specifies the header that your server uses for sending files
  config.action_dispatch.x_sendfile_header = "X-Sendfile"

  config.assets.js_compressor = :uglifier

  config.i18n.fallbacks = true

end
