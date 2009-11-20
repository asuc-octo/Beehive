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

class Solr::Indexer
  attr_reader :solr
  
  ***REMOVED*** TODO: document options!
  def initialize(data_source, mapper_or_mapping, options={})
    solr_url = options[:solr_url] || ENV["SOLR_URL"] || "http://localhost:8983/solr"
    @solr = Solr::Connection.new(solr_url, options) ***REMOVED***TODO - these options contain the solr_url and debug keys also, so tidy up what gets passed

    @data_source = data_source
    @mapper = mapper_or_mapping.is_a?(Hash) ? Solr::Importer::Mapper.new(mapper_or_mapping) : mapper_or_mapping

    @buffer_docs = options[:buffer_docs]
    @debug = options[:debug]
  end

  def index
    buffer = []
    @data_source.each do |record|
      document = @mapper.map(record)
      
      ***REMOVED*** TODO: check arrity of block, if 3, pass counter as 3rd argument
      yield(record, document) if block_given? ***REMOVED*** TODO check return of block, if not true then don't index, or perhaps if document.empty?
      
      buffer << document
      
      if !@buffer_docs || buffer.size == @buffer_docs
        add_docs(buffer)
        buffer.clear
      end
    end
    add_docs(buffer) if !buffer.empty?
    
    @solr.commit unless @debug
  end
  
  def add_docs(documents)
    @solr.add(documents) unless @debug
    puts documents.inspect if @debug
  end
end
