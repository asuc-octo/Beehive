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

***REMOVED*** For files with the first line containing field names
***REMOVED*** Currently not designed for enormous files, as all lines are
***REMOVED*** read into an array
class Solr::Importer::DelimitedFileSource
  include Enumerable
  
  def initialize(filename, splitter=/\t/)
    @filename = filename
    @splitter = splitter
  end

  def each
    lines = IO.readlines(@filename)
    headers = lines[0].split(@splitter).collect{|h| h.chomp}
    
    lines[1..-1].each do |line|
      data = headers.zip(line.split(@splitter).collect{|s| s.chomp})
      def data.[](key)
        self.assoc(key.to_s)[1]
      end
      
      yield(data)
    end
  end
  
end
