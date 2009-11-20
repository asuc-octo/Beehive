***REMOVED*** The ASF licenses this file to You under the Apache License, Version 2.0
***REMOVED*** (the "License"); you may not use this file except in compliance with
***REMOVED*** the License.  You may obtain a copy of the License at
***REMOVED***
***REMOVED***     http://www.apache.org/licenses/LICENSE-2.0
***REMOVED***
***REMOVED*** Unless required by applicable law or agreed to in writing, software
***REMOVED*** distributed under the License is distributed on an "AS IS" BASIS,
***REMOVED*** WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
***REMOVED*** See the License for the specific language governing permissions and
***REMOVED*** limitations under the License.

require 'net/http'

***REMOVED*** TODO: add a convenience method to POST a Solr .xml file, like Solr's example post.sh

class Solr::Connection
  attr_reader :url, :autocommit, :connection

  ***REMOVED*** create a connection to a solr instance using the url for the solr
  ***REMOVED*** application context:
  ***REMOVED***
  ***REMOVED***   conn = Solr::Connection.new("http://example.com:8080/solr")
  ***REMOVED***
  ***REMOVED*** if you would prefer to have all adds/updates autocommitted, 
  ***REMOVED*** use :autocommit => :on
  ***REMOVED***
  ***REMOVED***   conn = Solr::Connection.new('http://example.com:8080/solr', 
  ***REMOVED***     :autocommit => :on)

  def initialize(url="http://localhost:8983/solr", opts={})
    @url = URI.parse(url)
    unless @url.kind_of? URI::HTTP
      raise "invalid http url: ***REMOVED***{url}"
    end
  
    ***REMOVED*** TODO: Autocommit seems nice at one level, but it currently is confusing because
    ***REMOVED*** only calls to Connection***REMOVED***add/***REMOVED***update/***REMOVED***delete, though a Connection***REMOVED***send(AddDocument.new(...))
    ***REMOVED*** does not autocommit.  Maybe ***REMOVED***send should check for the request types that require a commit and
    ***REMOVED*** commit in ***REMOVED***send instead of the individual methods?
    @autocommit = opts[:autocommit] == :on
  
    ***REMOVED*** Not actually opening the connection yet, just setting up the persistent connection.
    @connection = Net::HTTP.new(@url.host, @url.port)
    
    @connection.read_timeout = opts[:timeout] if opts[:timeout]
  end

  ***REMOVED*** add a document to the index. you can pass in either a hash
  ***REMOVED***
  ***REMOVED***   conn.add(:id => 123, :title => 'Tlon, Uqbar, Orbis Tertius')
  ***REMOVED***
  ***REMOVED*** or a Solr::Document
  ***REMOVED***
  ***REMOVED***   conn.add(Solr::Document.new(:id => 123, :title = 'On Writing')
  ***REMOVED***
  ***REMOVED*** true/false will be returned to designate success/failure

  def add(doc)
    request = Solr::Request::AddDocument.new(doc)
    response = send(request)
    commit if @autocommit
    return response.ok?
  end

  ***REMOVED*** update a document in the index (really just an alias to add)

  def update(doc)
    return add(doc)
  end

  ***REMOVED*** performs a standard query and returns a Solr::Response::Standard
  ***REMOVED***
  ***REMOVED***   response = conn.query('borges')
  ***REMOVED*** 
  ***REMOVED*** alternative you can pass in a block and iterate over hits
  ***REMOVED***
  ***REMOVED***   conn.query('borges') do |hit|
  ***REMOVED***     puts hit
  ***REMOVED***   end
  ***REMOVED***
  ***REMOVED*** options include:
  ***REMOVED*** 
  ***REMOVED***   :sort, :default_field, :rows, :filter_queries, :debug_query,
  ***REMOVED***   :explain_other, :facets, :highlighting, :mlt,
  ***REMOVED***   :operator         => :or / :and
  ***REMOVED***   :start            => defaults to 0
  ***REMOVED***   :field_list       => array, defaults to ["*", "score"]

  def query(query, options={}, &action)
    ***REMOVED*** TODO: Shouldn't this return an exception if the Solr status is not ok?  (rather than true/false).
    create_and_send_query(Solr::Request::Standard, options.update(:query => query), &action)
  end
  
  ***REMOVED*** performs a dismax search and returns a Solr::Response::Standard
  ***REMOVED***
  ***REMOVED***   response = conn.search('borges')
  ***REMOVED*** 
  ***REMOVED*** options are same as query, but also include:
  ***REMOVED*** 
  ***REMOVED***   :tie_breaker, :query_fields, :minimum_match, :phrase_fields,
  ***REMOVED***   :phrase_slop, :boost_query, :boost_functions

  def search(query, options={}, &action)
    create_and_send_query(Solr::Request::Dismax, options.update(:query => query), &action)
  end

  ***REMOVED*** sends a commit message to the server
  def commit(options={})
    response = send(Solr::Request::Commit.new(options))
    return response.ok?
  end

  ***REMOVED*** sends an optimize message to the server
  def optimize
    response = send(Solr::Request::Optimize.new)
    return response.ok?
  end
  
  ***REMOVED*** pings the connection and returns true/false if it is alive or not
  def ping
    begin
      response = send(Solr::Request::Ping.new)
      return response.ok?
    rescue
      return false
    end
  end

  ***REMOVED*** delete a document from the index using the document id
  def delete(document_id)
    response = send(Solr::Request::Delete.new(:id => document_id))
    commit if @autocommit
    response.ok?
  end

  ***REMOVED*** delete using a query
  def delete_by_query(query)
    response = send(Solr::Request::Delete.new(:query => query))
    commit if @autocommit
    response.ok?
  end
  
  def info
    send(Solr::Request::IndexInfo.new)
  end
  
  ***REMOVED*** send a given Solr::Request and return a RubyResponse or XmlResponse
  ***REMOVED*** depending on the type of request
  def send(request)
    data = post(request)
    Solr::Response::Base.make_response(request, data)
  end

  ***REMOVED*** send the http post request to solr; for convenience there are shortcuts
  ***REMOVED*** to some requests: add(), query(), commit(), delete() or send()
  def post(request)
    response = @connection.post(@url.path + "/" + request.handler,
                                request.to_s,
                                { "Content-Type" => request.content_type })
  
    case response
    when Net::HTTPSuccess then response.body
    else
      response.error!
    end
  
  end
  
private
  
  def create_and_send_query(klass, options = {}, &action)
    request = klass.new(options)
    response = send(request)
    return response unless action
    response.each {|hit| action.call(hit)}
  end
  
end
