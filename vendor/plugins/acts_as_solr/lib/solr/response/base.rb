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

class Solr::Response::Base
  attr_reader :raw_response

  def initialize(raw_response)
    @raw_response = raw_response
  end

  ***REMOVED*** factory method for creating a Solr::Response::* from 
  ***REMOVED*** a request and the raw response content
  def self.make_response(request, raw)

    ***REMOVED*** make sure response format seems sane
    unless [:xml, :ruby].include?(request.response_format)
      raise Solr::Exception.new("unknown response format: ***REMOVED***{request.response_format}" )
    end

    ***REMOVED*** TODO: Factor out this case... perhaps the request object should provide the response class instead?  Or dynamically align by class name?
    ***REMOVED***       Maybe the request itself could have the response handling features that get mixed in with a single general purpose response object?
    
    begin
      klass = eval(request.class.name.sub(/Request/,'Response'))
    rescue NameError
      raise Solr::Exception.new("unknown request type: ***REMOVED***{request.class}")
    else
      klass.new(raw)
    end
    
  end

end
