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

require 'rexml/document'
require 'solr/exception'

class Solr::Response::Xml < Solr::Response::Base
  attr_reader :doc, :status_code, :status_message

  def initialize(xml)
    super
    ***REMOVED*** parse the xml
    @doc = REXML::Document.new(xml)

    ***REMOVED*** look for the result code and string 
    ***REMOVED*** <?xml version="1.0" encoding="UTF-8"?>
    ***REMOVED*** <response>
    ***REMOVED*** <lst name="responseHeader"><int name="status">0</int><int name="QTime">2</int></lst>
    ***REMOVED*** </response>
    result = REXML::XPath.first(@doc, './response/lst[@name="responseHeader"]/int[@name="status"]')
    if result
      @status_code =  result.text
      @status_message = result.text  ***REMOVED*** TODO: any need for a message?
    end
  rescue REXML::ParseException => e
    raise Solr::Exception.new("invalid response xml: ***REMOVED***{e}")
  end

  def ok?
    return @status_code == '0'
  end

end
