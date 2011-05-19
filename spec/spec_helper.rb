***REMOVED*** This file is copied to ~/spec when you run 'ruby script/generate rspec'
***REMOVED*** from the project root directory.
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path(File.join(File.dirname(__FILE__),'..','config','environment'))
require 'spec/autorun'
require 'spec/rails'

***REMOVED*** Uncomment the next line to use webrat's matchers
***REMOVED***require 'webrat/integrations/rspec-rails'

***REMOVED*** Requires supporting files with custom matchers and macros, etc,
***REMOVED*** in ./support/ and its subdirectories.
Dir[File.expand_path(File.join(File.dirname(__FILE__),'support','**','*.rb'))].each {|f| require f}

Spec::Runner.configure do |config|
  ***REMOVED*** If you're not using ActiveRecord you should remove these
  ***REMOVED*** lines, delete config/database.yml and disable :active_record
  ***REMOVED*** in your config/boot.rb
  config.use_transactional_fixtures = true
  config.use_instantiated_fixtures  = false
  config.fixture_path = Rails.root + '/spec/fixtures/'

  ***REMOVED*** == Fixtures
  ***REMOVED***
  ***REMOVED*** You can declare fixtures for each example_group like this:
  ***REMOVED***   describe "...." do
  ***REMOVED***     fixtures :table_a, :table_b
  ***REMOVED***
  ***REMOVED*** Alternatively, if you prefer to declare them only once, you can
  ***REMOVED*** do so right here. Just uncomment the next line and replace the fixture
  ***REMOVED*** names with your fixtures.
  ***REMOVED***
  ***REMOVED*** config.global_fixtures = :table_a, :table_b
  ***REMOVED***
  ***REMOVED*** If you declare global fixtures, be aware that they will be declared
  ***REMOVED*** for all of your examples, even those that don't use them.
  ***REMOVED***
  ***REMOVED*** You can also declare which fixtures to use (for example fixtures for test/fixtures):
  ***REMOVED***
  ***REMOVED*** config.fixture_path = Rails.root + '/spec/fixtures/'
  ***REMOVED***
  ***REMOVED*** == Mock Framework
  ***REMOVED***
  ***REMOVED*** RSpec uses it's own mocking framework by default. If you prefer to
  ***REMOVED*** use mocha, flexmock or RR, uncomment the appropriate line:
  ***REMOVED***
  ***REMOVED*** config.mock_with :mocha
  ***REMOVED*** config.mock_with :flexmock
  ***REMOVED*** config.mock_with :rr
  ***REMOVED***
  ***REMOVED*** == Notes
  ***REMOVED***
  ***REMOVED*** For more information take a look at Spec::Runner::Configuration and Spec::Runner
end
