require 'boot'
require 'lib/activerecord_test_connector'

***REMOVED*** setup the connection
ActiveRecordTestConnector.setup

***REMOVED*** load all fixtures
Fixtures.create_fixtures(ActiveRecordTestConnector::FIXTURES_PATH, ActiveRecord::Base.connection.tables)

require 'will_paginate'
WillPaginate.enable_activerecord
