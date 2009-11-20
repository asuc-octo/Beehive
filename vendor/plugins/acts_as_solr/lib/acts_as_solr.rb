***REMOVED*** Copyright (c) 2006 Erik Hatcher, Thiago Jackiw
***REMOVED***
***REMOVED*** Permission is hereby granted, free of charge, to any person obtaining a copy
***REMOVED*** of this software and associated documentation files (the "Software"), to deal
***REMOVED*** in the Software without restriction, including without limitation the rights
***REMOVED*** to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
***REMOVED*** copies of the Software, and to permit persons to whom the Software is
***REMOVED*** furnished to do so, subject to the following conditions:
***REMOVED***
***REMOVED*** The above copyright notice and this permission notice shall be included in all
***REMOVED*** copies or substantial portions of the Software.
***REMOVED***
***REMOVED*** THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
***REMOVED*** IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
***REMOVED*** FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
***REMOVED*** AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
***REMOVED*** LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
***REMOVED*** OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
***REMOVED*** SOFTWARE.

require 'active_record'
require 'rexml/document'
require 'net/http'
require 'yaml'

require File.dirname(__FILE__) + '/solr'
require File.dirname(__FILE__) + '/acts_methods'
require File.dirname(__FILE__) + '/class_methods'
require File.dirname(__FILE__) + '/instance_methods'
require File.dirname(__FILE__) + '/common_methods'
require File.dirname(__FILE__) + '/deprecation'
require File.dirname(__FILE__) + '/search_results'
require File.dirname(__FILE__) + '/lazy_document'
module ActsAsSolr
  
  class Post    
    def self.execute(request)
      begin
        if File.exists?(RAILS_ROOT+'/config/solr.yml')
          config = YAML::load_file(RAILS_ROOT+'/config/solr.yml')
          url = config[RAILS_ENV]['url']
          ***REMOVED*** for backwards compatibility
          url ||= "http://***REMOVED***{config[RAILS_ENV]['host']}:***REMOVED***{config[RAILS_ENV]['port']}/***REMOVED***{config[RAILS_ENV]['servlet_path']}"
        else
          url = 'http://localhost:8982/solr'
        end
        connection = Solr::Connection.new(url)
        return connection.send(request)
      rescue 
        raise "Couldn't connect to the Solr server at ***REMOVED***{url}. ***REMOVED***{$!}"
        false
      end
    end
  end
  
end

***REMOVED*** reopen ActiveRecord and include the acts_as_solr method
ActiveRecord::Base.extend ActsAsSolr::ActsMethods
