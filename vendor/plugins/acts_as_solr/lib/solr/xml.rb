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

module Solr::XML
end

begin
  
  ***REMOVED*** If we can load rubygems and libxml-ruby...
  require 'rubygems'
  require 'xml/libxml'
  raise "acts_as_solr requires libxml-ruby 0.7 or greater" unless XML::Node.public_instance_methods.include?("attributes")

  ***REMOVED*** then make a few modifications to XML::Node so it can stand in for REXML::Element
  class XML::Node
    ***REMOVED*** element.add_element(another_element) should work
    alias_method :add_element, :<<


    ***REMOVED*** element.text = "blah" should work
    def text=(x)
      self << x.to_s
    end
  end
  
  ***REMOVED*** And use XML::Node for our XML generation
  Solr::XML::Element = XML::Node
  
rescue LoadError => e ***REMOVED*** If we can't load either rubygems or libxml-ruby
  puts "Requiring REXML"
  ***REMOVED*** Just use REXML.
  require 'rexml/document'
  Solr::XML::Element = REXML::Element
  
end