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

class Solr::Request::Dismax < Solr::Request::Standard

  VALID_PARAMS.replace(VALID_PARAMS + [:tie_breaker, :query_fields, :minimum_match, :phrase_fields, :phrase_slop,
                                       :boost_query, :boost_functions])

  def initialize(params)
    @alternate_query = params.delete(:alternate_query)
    @sort_values = params.delete(:sort)
    
    super
    
    @query_type = "dismax"
  end
  
  def to_hash
    hash = super
    hash[:tie] = @params[:tie_breaker]
    hash[:mm]  = @params[:minimum_match]
    hash[:qf]  = @params[:query_fields]
    hash[:pf]  = @params[:phrase_fields]
    hash[:ps]  = @params[:phrase_slop]
    hash[:bq]  = @params[:boost_query]
    hash[:bf]  = @params[:boost_functions]
    hash["q.alt"] = @alternate_query
    ***REMOVED*** FIXME: 2007-02-13 <coda.hale@gmail.com> --  This code is duplicated in
    ***REMOVED*** Solr::Request::Standard. It should be refactored into a single location.
    hash[:sort] = @sort_values.collect do |sort|
      key = sort.keys[0]
      "***REMOVED***{key.to_s} ***REMOVED***{sort[key] == :descending ? 'desc' : 'asc'}"
    end.join(',') if @sort_values
    return hash
  end

end