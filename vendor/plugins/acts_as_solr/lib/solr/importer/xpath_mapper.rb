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

begin
  require 'xml/libxml'

  ***REMOVED*** For files with the first line containing field names
  class Solr::Importer::XPathMapper < Solr::Importer::Mapper
    def field_data(doc, xpath)
      doc.find(xpath.to_s).collect do |node|
        case node
          when XML::Attr
            node.value
          when XML::Node
            node.content
        end
      end
    end
  end
rescue LoadError => e ***REMOVED*** If we can't load libxml
  class Solr::Importer::XPathMapper
    def initialize(mapping, options={})
      raise "libxml not installed"
    end
  end
end
