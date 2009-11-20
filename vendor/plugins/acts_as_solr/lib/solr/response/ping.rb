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

require 'rexml/xpath'

class Solr::Response::Ping < Solr::Response::Xml

  def initialize(xml)
    super
    @ok = REXML::XPath.first(@doc, './solr/ping') ? true : false
  end

  ***REMOVED*** returns true or false depending on whether the ping
  ***REMOVED*** was successful or not
  def ok?
    @ok
  end

end
