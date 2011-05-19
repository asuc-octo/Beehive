ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  ***REMOVED*** Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  ***REMOVED***
  ***REMOVED*** Note: You'll currently still have to declare fixtures explicitly in integration tests
  ***REMOVED*** -- they do not yet inherit this setting
  fixtures :all

  ***REMOVED*** Add more helper methods to be used by all tests here...
end
