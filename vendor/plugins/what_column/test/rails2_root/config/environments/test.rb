***REMOVED*** Settings specified here will take precedence over those in config/environment.rb

***REMOVED*** The test environment is used exclusively to run your application's
***REMOVED*** test suite.  You never need to work with it otherwise.  Remember that
***REMOVED*** your test database is "scratch space" for the test suite and is wiped
***REMOVED*** and recreated between test runs.  Don't rely on the data there!
config.cache_classes = true

***REMOVED*** Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

***REMOVED*** Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_controller.perform_caching             = false
config.action_view.cache_template_loading            = true

***REMOVED*** Disable request forgery protection in test environment
config.action_controller.allow_forgery_protection    = false

***REMOVED*** Tell Action Mailer not to deliver emails to the real world.
***REMOVED*** The :test delivery method accumulates sent emails in the
***REMOVED*** ActionMailer::Base.deliveries array.
config.action_mailer.delivery_method = :test

***REMOVED*** Use SQL instead of Active Record's schema dumper when creating the test database.
***REMOVED*** This is necessary if your schema can't be completely dumped by the schema dumper,
***REMOVED*** like if you have constraints or database-specific column types
***REMOVED*** config.active_record.schema_format = :sql