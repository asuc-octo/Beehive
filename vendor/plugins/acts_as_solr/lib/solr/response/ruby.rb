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

class Solr::Response::Ruby < Solr::Response::Base
  attr_reader :data, :header

  def initialize(ruby_code)
    super
    begin
      ***REMOVED***TODO: what about pulling up data/header/response to ResponseBase,
      ***REMOVED***      or maybe a new middle class like SelectResponseBase since
      ***REMOVED***      all Select queries return this same sort of stuff??
      ***REMOVED***      XML (&wt=xml) and Ruby (&wt=ruby) responses contain exactly the same structure.
      ***REMOVED***      a goal of solrb is to make it irrelevant which gets used under the hood, 
      ***REMOVED***      but favor Ruby responses.
      @data = eval(ruby_code)
      @header = @data['responseHeader']
      raise "response should be a hash" unless @data.kind_of? Hash
      raise "response header missing" unless @header.kind_of? Hash
    rescue SyntaxError => e
      raise Solr::Exception.new("invalid ruby code: ***REMOVED***{e}")
    end
  end

  def ok?
    @header['status'] == 0
  end

  def query_time
    @header['QTime']
  end
  
end
