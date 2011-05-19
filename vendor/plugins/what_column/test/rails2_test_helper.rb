def rails_root
  File.dirname(__FILE__) + '/rails2_root'
end

require "***REMOVED***{rails_root}/config/environment.rb"

***REMOVED*** Load the testing framework
require 'test_help'

***REMOVED*** Run the migrations

ActiveRecord::Migration.verbose = false
ActiveRecord::Migrator.migrate("***REMOVED***{rails_root}/db/migrate")

require 'shoulda'
require 'mocha'
