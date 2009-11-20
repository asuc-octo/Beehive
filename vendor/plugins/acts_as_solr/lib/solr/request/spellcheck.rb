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

class Solr::Request::Spellcheck < Solr::Request::Select

  def initialize(params)
    super('spellchecker')
    @params = params
  end
  
  def to_hash
    hash = super
    hash[:q] = @params[:query]
    hash[:suggestionCount] = @params[:suggestion_count]
    hash[:accuracy] = @params[:accuracy]
    hash[:onlyMorePopular] = @params[:only_more_popular]
    hash[:cmd] = @params[:command]
    return hash
  end

end