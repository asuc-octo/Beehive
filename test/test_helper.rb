ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'test_help'

class ActiveSupport::TestCase
  ***REMOVED*** Transactional fixtures accelerate your tests by wrapping each test method
  ***REMOVED*** in a transaction that's rolled back on completion.  This ensures that the
  ***REMOVED*** test database remains unchanged so your fixtures don't have to be reloaded
  ***REMOVED*** between every test method.  Fewer database queries means faster tests.
  ***REMOVED***
  ***REMOVED*** Read Mike Clark's excellent walkthrough at
  ***REMOVED***   http://clarkware.com/cgi/blosxom/2005/10/24***REMOVED***Rails10FastTesting
  ***REMOVED***
  ***REMOVED*** Every Active Record database supports transactions except MyISAM tables
  ***REMOVED*** in MySQL.  Turn off transactional fixtures in this case; however, if you
  ***REMOVED*** don't care one way or the other, switching from MyISAM to InnoDB tables
  ***REMOVED*** is recommended.
  ***REMOVED***
  ***REMOVED*** The only drawback to using transactional fixtures is when you actually 
  ***REMOVED*** need to test transactions.  Since your test is bracketed by a transaction,
  ***REMOVED*** any transactions started in your code will be automatically rolled back.
  self.use_transactional_fixtures = true

  ***REMOVED*** Instantiated fixtures are slow, but give you @david where otherwise you
  ***REMOVED*** would need people(:david).  If you don't want to migrate your existing
  ***REMOVED*** test cases which use the @david style and don't mind the speed hit (each
  ***REMOVED*** instantiated fixtures translates to a database query per test method),
  ***REMOVED*** then set this back to true.
  self.use_instantiated_fixtures  = false

  ***REMOVED*** Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  ***REMOVED***
  ***REMOVED*** Note: You'll currently still have to declare fixtures explicitly in integration tests
  ***REMOVED*** -- they do not yet inherit this setting
  fixtures :all

  ***REMOVED*** Add more helper methods to be used by all tests here...
end
