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

class Solr::Request::Base
  
  
  ***REMOVED***TODO : Add base support for the debugQuery flag, and such that the response provides debug output easily

  ***REMOVED*** returns either :xml or :ruby depending on what the
  ***REMOVED*** response type is for a given request
  
  def response_format
    raise "unknown request type: ***REMOVED***{self.class}"
  end
  
  def content_type
    'text/xml; charset=utf-8'
  end

  ***REMOVED*** returns the solr handler or url fragment that can 
  ***REMOVED*** respond to this type of request
  
  def handler
    raise "unknown request type: ***REMOVED***{self.class}"
  end

end
