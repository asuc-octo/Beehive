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

require 'solr/xml'

class Solr::Request::Commit < Solr::Request::Update

  def initialize(options={})
    @wait_searcher = options[:wait_searcher] || true
    @wait_flush = options[:wait_flush] || true
  end


  def to_s
    e = Solr::XML::Element.new('commit')
    e.attributes['waitSearcher'] = @wait_searcher ? 'true' : 'false'
    e.attributes['waitFlush'] = @wait_flush ? 'true' : 'false'
    
    e.to_s
  end

end
