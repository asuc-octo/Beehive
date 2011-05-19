require File.expand_path('../boot', __FILE__)

require 'rails/all'

***REMOVED*** If you have a Gemfile, require the gems listed there, including any gems
***REMOVED*** you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env) if defined?(Bundler)

module Rails3Root
  class Application < Rails::Application
    ***REMOVED*** Settings in config/environments/* take precedence over those specified here.
    ***REMOVED*** Application configuration should go into files in config/initializers
    ***REMOVED*** -- all .rb files in that directory are automatically loaded.

    ***REMOVED*** Custom directories with classes and modules you want to be autoloadable.
    ***REMOVED*** config.autoload_paths += %W(***REMOVED***{config.root}/extras)

    ***REMOVED*** Only load the plugins named here, in the order given (default is alphabetical).
    ***REMOVED*** :all can be used as a placeholder for all plugins not explicitly named.
    ***REMOVED*** config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    ***REMOVED*** Activate observers that should always be running.
    ***REMOVED*** config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    ***REMOVED*** Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    ***REMOVED*** Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    ***REMOVED*** config.time_zone = 'Central Time (US & Canada)'

    ***REMOVED*** The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    ***REMOVED*** config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    ***REMOVED*** config.i18n.default_locale = :de

    ***REMOVED*** JavaScript files you want as :defaults (application.js is always included).
    ***REMOVED*** config.action_view.javascript_expansions[:defaults] = %w(jquery rails)

    ***REMOVED*** Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    ***REMOVED*** Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]
  end
end
