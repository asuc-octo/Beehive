***REMOVED*** This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'

***REMOVED*** Requires supporting ruby files with custom matchers and macros, etc,
***REMOVED*** in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  ***REMOVED*** == Mock Framework
  ***REMOVED***
  ***REMOVED*** If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  ***REMOVED***
  ***REMOVED*** config.mock_with :mocha
  ***REMOVED*** config.mock_with :flexmock
  ***REMOVED*** config.mock_with :rr
  config.mock_with :rspec

  ***REMOVED*** Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "***REMOVED***{::Rails.root}/spec/fixtures"

  ***REMOVED*** If you're not using ActiveRecord, or you'd prefer not to run each of your
  ***REMOVED*** examples within a transaction, remove the following line or assign false
  ***REMOVED*** instead of true.
  config.use_transactional_fixtures = true
end
