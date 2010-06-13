require 'test/unit'
require 'fileutils'
require 'rubygems'
require 'active_record'
require 'active_record/fixtures'
require 'mocha'

***REMOVED*** Mock out the required environment variables.
***REMOVED*** Do this before requiring AAI.
class Rails
  def self.root
    Dir.pwd
  end
  def self.env
    'test'
  end
end

require File.dirname(__FILE__) + '/../lib/acts_as_indexed'

ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__) + '/test.log')
ActiveRecord::Base.configurations = YAML::load(IO.read(File.dirname(__FILE__) + '/database.yml'))
ActiveRecord::Base.establish_connection(ENV['DB'] || 'sqlite3')

***REMOVED*** Load Schema
load(File.dirname(__FILE__) + '/schema.rb')

***REMOVED*** Load model.
$LOAD_PATH.unshift(File.dirname(__FILE__) + '/fixtures/')

class ActiveSupport::TestCase ***REMOVED***:nodoc:
  include ActiveRecord::TestFixtures
  self.fixture_path = File.dirname(__FILE__) + '/fixtures/'
  self.use_transactional_fixtures = true
  self.use_instantiated_fixtures  = false
  
  def destroy_index
    `rm -rdf ***REMOVED***{index_loc}`
  end
  
  def build_index
    ***REMOVED*** Makes a query to invoke the index build.
    assert_equal [], Post.find_with_index('badger')
    assert File.exists?(index_loc)
    true
  end
  
  def index_loc
    File.join(Rails.root,'index')
  end
  
end
