require 'test_helper'
require 'performance_test_help'

***REMOVED*** Profiling results for each test method are written to tmp/performance.
class BrowsingTest < ActionController::PerformanceTest
  def test_homepage
    get '/'
  end
end
