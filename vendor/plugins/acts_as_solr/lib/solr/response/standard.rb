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

class Solr::Response::Standard < Solr::Response::Ruby
  FacetValue = Struct.new(:name, :value)
  include Enumerable
  
  def initialize(ruby_code)
    super
    @response = @data['response']
    raise "response section missing" unless @response.kind_of? Hash
  end

  def total_hits
    @response['numFound']
  end

  def start
    @response['start']
  end

  def hits
    @response['docs']
  end

  def max_score
    @response['maxScore']
  end
  
  ***REMOVED*** TODO: consider the use of json.nl parameter
  def field_facets(field)
    facets = []
    values = @data['facet_counts']['facet_fields'][field]
    Solr::Util.paired_array_each(values) do |key, value|
      facets << FacetValue.new(key, value)
    end
    
    facets
  end
  
  def highlighted(id, field)
    @data['highlighting'][id.to_s][field.to_s] rescue nil
  end
  
  ***REMOVED*** supports enumeration of hits
  ***REMOVED*** TODO revisit - should this iterate through *all* hits by re-requesting more?
  def each
    @response['docs'].each {|hit| yield hit}
  end

end
