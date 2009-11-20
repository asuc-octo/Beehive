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

class Solr::Util
  ***REMOVED*** paired_array_each([key1,value1,key2,value2]) yields twice:
  ***REMOVED***     |key1,value1|  and |key2,value2|
  def self.paired_array_each(a, &block)
    0.upto(a.size / 2 - 1) do |i|
      n = i * 2
      yield(a[n], a[n+1])
    end
  end

  ***REMOVED*** paired_array_to_hash([key1,value1,key2,value2]) => {key1 => value1, key2, value2}
  def self.paired_array_to_hash(a)
    Hash[*a]
  end
  
  def self.query_parser_escape(string)
    ***REMOVED*** backslash prefix everything that isn't a word character
    string.gsub(/(\W)/,'\\\\\1')
  end
end
