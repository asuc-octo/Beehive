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
require 'solr/field'

class Solr::Document
  include Enumerable
  attr_accessor :boost
  attr_reader :fields

  ***REMOVED*** Create a new Solr::Document, optionally passing in a hash of 
  ***REMOVED*** key/value pairs for the fields
  ***REMOVED***
  ***REMOVED***   doc = Solr::Document.new(:creator => 'Jorge Luis Borges')
  def initialize(hash={})
    @fields = []
    self << hash
  end

  ***REMOVED*** Append a Solr::Field
  ***REMOVED***
  ***REMOVED***   doc << Solr::Field.new(:creator => 'Jorge Luis Borges')
  ***REMOVED***
  ***REMOVED*** If you are truly lazy you can simply pass in a hash:
  ***REMOVED***
  ***REMOVED***   doc << {:creator => 'Jorge Luis Borges'}
  def <<(fields)
    case fields
    when Hash
      fields.each_pair do |name,value|
        if value.respond_to?(:each) && !value.is_a?(String)
          value.each {|v| @fields << Solr::Field.new(name => v)}
        else
          @fields << Solr::Field.new(name => value)
        end
      end
    when Solr::Field
      @fields << fields
    else
      raise "must pass in Solr::Field or Hash"
    end
  end

  ***REMOVED*** shorthand to allow hash lookups
  ***REMOVED***   doc['name']
  def [](name)
    field = @fields.find {|f| f.name == name.to_s}
    return field.value if field
    return nil
  end

  ***REMOVED*** shorthand to assign as a hash
  def []=(name,value)
    @fields << Solr::Field.new(name => value)
  end

  ***REMOVED*** convert the Document to a REXML::Element 
  def to_xml
    e = Solr::XML::Element.new 'doc'
    e.attributes['boost'] = @boost.to_s if @boost
    @fields.each {|f| e.add_element(f.to_xml)}
    return e
  end

  def each(*args, &blk)
    fields.each(&blk)
  end
end
