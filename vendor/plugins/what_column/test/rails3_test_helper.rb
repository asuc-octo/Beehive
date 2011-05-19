def rails_root
  File.dirname(__FILE__) + '/rails3_root'
end

ENV['BUNDLE_GEMFILE'] = rails_root + '/Gemfile'
require "***REMOVED***{rails_root}/config/environment.rb"

***REMOVED*** Load the testing framework
require 'rails/test_help'

***REMOVED*** Run the migrations

ActiveRecord::Migration.verbose = true
ActiveRecord::Migrator.migrate("***REMOVED***{rails_root}/db/migrate")


