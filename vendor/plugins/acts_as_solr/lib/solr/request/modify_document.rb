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
require 'solr/request/base'
require 'solr/document'
require 'solr/request/update'

class Solr::Request::ModifyDocument < Solr::Request::Update

  ***REMOVED*** Example: ModifyDocument.new(:id => 10, :overwrite => {:field_name => "new value"})
  def initialize(update_data)
    modes = []
    @doc = {}
    [:overwrite, :append, :distinct, :increment, :delete].each do |mode|
      field_data = update_data[mode]
      if field_data
        field_data.each do |field_name, field_value|
          modes << "***REMOVED***{field_name}:***REMOVED***{mode.to_s.upcase}"
          @doc[field_name] = field_value if field_value  ***REMOVED*** if value is nil, omit so it can be removed
        end
        update_data.delete mode
      end
    end
    @mode = modes.join(",")
    
    ***REMOVED*** only one key should be left over, the id
    @doc[update_data.keys[0].to_s] = update_data.values[0]
  end

  ***REMOVED*** returns the request as a string suitable for posting
  def to_s
    e = Solr::XML::Element.new 'add'
    e.add_element(Solr::Document.new(@doc).to_xml)
    return e.to_s
  end
  
  def handler
    "update?mode=***REMOVED***{@mode}"
  end
  
end
