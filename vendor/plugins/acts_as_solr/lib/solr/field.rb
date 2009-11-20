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
require 'time'

class Solr::Field
  VALID_PARAMS = [:boost]
  attr_accessor :name
  attr_accessor :value
  attr_accessor :boost

  ***REMOVED*** Accepts an optional <tt>:boost</tt> parameter, used to boost the relevance of a particular field.
  def initialize(params)
    @boost = params[:boost]
    name_key = (params.keys - VALID_PARAMS).first
    @name, @value = name_key.to_s, params[name_key]
    ***REMOVED*** Convert any Time values into UTC/XML schema format (which Solr requires).
    @value = @value.respond_to?(:utc) ? @value.utc.xmlschema : @value.to_s
  end

  def to_xml
    e = Solr::XML::Element.new 'field'
    e.attributes['name'] = @name
    e.attributes['boost'] = @boost.to_s if @boost
    e.text = @value
    return e
  end

end
