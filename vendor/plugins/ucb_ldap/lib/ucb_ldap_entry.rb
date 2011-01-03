module UCB
  module LDAP
    ***REMOVED******REMOVED***
    ***REMOVED*** = UCB::LDAP::Entry
    ***REMOVED*** 
    ***REMOVED*** Abstract class representing an entry in the UCB LDAP directory.  You
    ***REMOVED*** won't ever deal with Entry instances, but instead instances of Entry
    ***REMOVED*** sub-classes.
    ***REMOVED*** 
    ***REMOVED*** == Accessing LDAP Attributes
    ***REMOVED*** 
    ***REMOVED*** You will not see the attributes documented in the
    ***REMOVED*** instance method section of the documentation for Entry sub-classes,
    ***REMOVED*** even though you can access them as
    ***REMOVED*** if they _were_ instance methods.
    ***REMOVED***
    ***REMOVED***   person = Person.find_by_uid("123")  ***REMOVED***=> ***REMOVED***<UCB::LDAP::Person ..>
    ***REMOVED***   people.givenname                    ***REMOVED***=> ["John"]
    ***REMOVED***   
    ***REMOVED*** Entry sub-classes may have convenience methods that
    ***REMOVED*** allow for accessing attributes by friendly names:
    ***REMOVED*** 
    ***REMOVED***   person = Person.person_by_uid("123")  ***REMOVED***=> ***REMOVED***<UCB::LDAP::Person ..>
    ***REMOVED***   person.firstname                      ***REMOVED***=> "John"
    ***REMOVED***
    ***REMOVED*** See the sub-class documentation for specifics.
    ***REMOVED*** 
    ***REMOVED*** ===Single- / Multi-Value Attributes
    ***REMOVED***
    ***REMOVED*** Attribute values are returned as arrays or scalars based on how 
    ***REMOVED*** they are defined in the LDAP schema.  
    ***REMOVED***
    ***REMOVED*** Entry subclasses may have convenience
    ***REMOVED*** methods that return scalars even though the schema defines
    ***REMOVED*** the unerlying attribute as multi-valued becuase in practice the are single-valued.
    ***REMOVED*** 
    ***REMOVED*** === Attribute Types
    ***REMOVED*** 
    ***REMOVED*** Attribute values are stored as arrays of strings in LDAP, but 
    ***REMOVED*** when accessed through Entry sub-class methods are returned
    ***REMOVED*** cast to their Ruby type as defined in the schema.  Types are one of:
    ***REMOVED***
    ***REMOVED*** * string
    ***REMOVED*** * integer
    ***REMOVED*** * boolean
    ***REMOVED*** * datetime
    ***REMOVED***
    ***REMOVED*** === Missing Attribute Values
    ***REMOVED*** 
    ***REMOVED*** If an attribute value is not present, the value returned depends on
    ***REMOVED*** type and multi/single value field:
    ***REMOVED***
    ***REMOVED*** * empty multi-valued attributes return an empty array ([])
    ***REMOVED*** * empty booleans return +false+
    ***REMOVED*** * everything else returns +nil+ if empty
    ***REMOVED***
    ***REMOVED*** Attempting to get or set an attribute value for an invalid attriubte name
    ***REMOVED*** will raise a BadAttributeNameException.
    ***REMOVED***
    ***REMOVED*** == Updating LDAP
    ***REMOVED***
    ***REMOVED*** If your bind has privleges for updating the directory you can update
    ***REMOVED*** the directory using methods of Entry sub-classes.  Make sure you call
    ***REMOVED*** UCB::LDAP.authenticate before calling any update methods.
    ***REMOVED***
    ***REMOVED*** There are three pairs of update methods that behave like Rails ActiveRecord
    ***REMOVED*** methods of the same name.  These methods are fairly thin wrappers around
    ***REMOVED*** standard LDAP update commands.
    ***REMOVED***
    ***REMOVED*** The "bang" methods (those ending in "!") differ from their bangless 
    ***REMOVED*** counterparts in that the bang methods raise +DirectoryNotUpdatedException+
    ***REMOVED*** on failure, while the bangless return +false+.
    ***REMOVED***
    ***REMOVED*** * ***REMOVED***create/***REMOVED***create! - class methods that do LDAP add
    ***REMOVED*** * ***REMOVED***update_attributes/***REMOVED***update_attributes! - instance methods that do LDAP modify
    ***REMOVED*** * ***REMOVED***delete/***REMOVED***delete! - instance methods that do LDAP delete
    ***REMOVED***
    class Entry
      
      ***REMOVED******REMOVED***
      ***REMOVED*** Returns new instance of UCB::LDAP::Entry.  The argument
      ***REMOVED*** net_ldap_entry is an instance of Net::LDAP::Entry.
      ***REMOVED*** 
      ***REMOVED*** You should not need to create any UCB::LDAP::Entry instances;
      ***REMOVED*** they are created by calls to UCB::LDAP.search and friends.
      ***REMOVED***
      def initialize(net_ldap_entry) ***REMOVED***:nodoc:
        ***REMOVED*** Don't store Net::LDAP entry in object since it uses the block
        ***REMOVED*** initialization method of Hash which can't be marshalled ... this 
        ***REMOVED*** means it can't be stored in a Rails session.
        @attributes = {}
        net_ldap_entry.each do |attr, value|
          @attributes[canonical(attr)] = value.map{|v| v.dup}
        end
      end
      
      ***REMOVED******REMOVED***
      ***REMOVED*** <tt>Hash</tt> of attributes returned from underlying NET::LDAP::Entry
      ***REMOVED*** instance.  Hash keys are ***REMOVED***canonical attribute names, hash values are attribute
      ***REMOVED*** values <em>as returned from LDAP</em>, i.e. arrays.
      ***REMOVED*** 
      ***REMOVED*** You should most likely be referencing attributes as if they were
      ***REMOVED*** instance methods rather than directly through this method.  See top of
      ***REMOVED*** this document.
      ***REMOVED***
      def attributes
        @attributes
      end
      
      ***REMOVED******REMOVED***
      ***REMOVED*** Returns the value of the <em>Distinguished Name</em> attribute.
      ***REMOVED***
      def dn
        attributes[canonical(:dn)]
      end
    
      def canonical(string_or_symbol) ***REMOVED***:nodoc:
        self.class.canonical(string_or_symbol)
      end
      
      ***REMOVED******REMOVED***
      ***REMOVED*** Update an existing entry.  Returns entry if successful else false.
      ***REMOVED***
      ***REMOVED***   attrs = {:attr1 => "new_v1", :attr2 => "new_v2"}
      ***REMOVED***   entry.update_attributes(attrs)
      ***REMOVED***
      def update_attributes(attrs)
        attrs.each{|k, v| self.send("***REMOVED***{k}=", v)}        
        if modify()
          @attributes = self.class.find_by_dn(dn).attributes.dup
          return true
        end
        false
      end

      ***REMOVED******REMOVED***
      ***REMOVED*** Same as ***REMOVED***update_attributes(), but raises DirectoryNotUpdated on failure.
      ***REMOVED***
      def update_attributes!(attrs)
        update_attributes(attrs) || raise(DirectoryNotUpdatedException)
      end

      ***REMOVED******REMOVED***
      ***REMOVED*** Delete entry.  Returns +true+ on sucess, +false+ on failure.
      ***REMOVED***
      def delete
        net_ldap.delete(:dn => dn)
      end

      ***REMOVED******REMOVED***
      ***REMOVED*** Same as ***REMOVED***delete() except raises DirectoryNotUpdated on failure.
      ***REMOVED***
      def delete!
        delete || raise(DirectoryNotUpdatedException)
      end
      
      def net_ldap
        self.class.net_ldap
      end
      
      
      private unless $TESTING
      
      ***REMOVED******REMOVED***
      ***REMOVED*** Used to get/set attribute values.
      ***REMOVED***
      ***REMOVED*** If we can't make an attribute name out of method, let
      ***REMOVED*** regular method_missing() handle it.
      ***REMOVED***
      def method_missing(method, *args) ***REMOVED***:nodoc:
        setter_method?(method) ? value_setter(method, *args) : value_getter(method)
      rescue BadAttributeNameException
        return super
      end

      ***REMOVED******REMOVED***
      ***REMOVED*** Returns +true+ if _method_ is a "setter", i.e., ends in "=".
      ***REMOVED***
      def setter_method?(method)
        method.to_s[-1, 1] == "="
      end
      
      ***REMOVED******REMOVED***
      ***REMOVED*** Called by method_missing() to get an attribute value.
      ***REMOVED***
      def value_getter(method)
        schema_attribute = self.class.schema_attribute(method)
        raw_value = attributes[canonical(schema_attribute.name)]
        schema_attribute.get_value(raw_value)
      end
      
      ***REMOVED******REMOVED***
      ***REMOVED*** Called by method_missing() to set an attribute value.
      ***REMOVED***
      def value_setter(method, *args)
        schema_attribute = self.class.schema_attribute(method.to_s.chop)
        attr_key = canonical(schema_attribute.name)
        assigned_attributes[attr_key] = schema_attribute.ldap_value(args[0])
      end
    
      def assigned_attributes
        @assigned_attributes ||= {}
      end
    
      def modify_operations
        ops = []
        assigned_attributes.keys.sort_by{|k| k.to_s}.each do |key|
          value = assigned_attributes[key]
          op = value.nil? ? :delete : :replace
          ops << [op, key, value]
        end
        ops
      end
    
      def modify()
        if UCB::LDAP.net_ldap.modify(:dn => dn, :operations => modify_operations)
          @assigned_attributes = nil
          return true
        end
        false
      end

      ***REMOVED*** Class methods
      class << self
        
        public
        
        ***REMOVED*** Creates and returns new entry.  Returns +false+ if unsuccessful.
        ***REMOVED*** Sets :objectclass key of <em>args[:attributes]</em> to 
        ***REMOVED*** object_classes read from schema.
        ***REMOVED***
        ***REMOVED***   dn = "uid=999999,ou=people,dc=example,dc=com"
        ***REMOVED***   attr = {
        ***REMOVED***     :uid => "999999",
        ***REMOVED***     :mail => "gsmith@example.com"
        ***REMOVED***   }
        ***REMOVED***   
        ***REMOVED***   EntrySubClass.create(:dn => dn, :attributes => attr)  ***REMOVED***=> ***REMOVED***<UCB::LDAP::EntrySubClass ..>
        ***REMOVED***
        ***REMOVED*** Caller is responsible for setting :dn and :attributes correctly,
        ***REMOVED*** as well as any other validation.
        ***REMOVED***
        def create(args)
          args[:attributes][:objectclass] = object_classes
          result = net_ldap.add(args)
          result or return false
          find_by_dn(args[:dn])
        end
        
        ***REMOVED******REMOVED***
        ***REMOVED*** Returns entry whose distinguised name is _dn_.
        def find_by_dn(dn)
          search(
            :base => dn,
            :scope => Net::LDAP::SearchScope_BaseObject,
            :filter => "objectClass=*"
          ).first
        end

        ***REMOVED******REMOVED***
        ***REMOVED*** Same as ***REMOVED***create(), but raises DirectoryNotUpdated on failure.
        def create!(args)
          create(args) || raise(DirectoryNotUpdatedException)          
        end

        ***REMOVED******REMOVED***
        ***REMOVED*** Returns a new Net::LDAP::Filter that is the result of combining
        ***REMOVED*** <em>filters</em> using <em>operator</em> (<em>filters</em> is 
        ***REMOVED*** an +Array+ of Net::LDAP::Filter).
        ***REMOVED***
        ***REMOVED*** See Net::LDAP***REMOVED***& and Net::LDAP***REMOVED***| for details.
        ***REMOVED***
        ***REMOVED***   f1 = Net::LDAP::Filter.eq("lastname", "hansen")
        ***REMOVED***   f2 = Net::LDAP::Filter.eq("firstname", "steven")
        ***REMOVED***   
        ***REMOVED***   combine_filters([f1, f2])      ***REMOVED*** same as: f1 & f2
        ***REMOVED***   combine_filters([f1, f2], '|') ***REMOVED*** same as: f1 | f2
        ***REMOVED***
        def combine_filters(filters, operator = '&')
          filters.inject{|accum, filter| accum.send(operator, filter)}
        end
        
        ***REMOVED******REMOVED***
        ***REMOVED*** Returns Net::LDAP::Filter.  Allows for <em>filter</em> to
        ***REMOVED*** be a +Hash+ of :key => value.  Filters are combined with "&".
        ***REMOVED***
        ***REMOVED***   UCB::LDAP::Entry.make_search_filter(:uid => '123') 
        ***REMOVED***   UCB::LDAP::Entry.make_search_filter(:a1 => v1, :a2 => v2)
        ***REMOVED***
        def make_search_filter(filter)
          return filter if filter.instance_of?  Net::LDAP::Filter
          return filter if filter.instance_of?  String
          
          filters = []
          ***REMOVED*** sort so result is predictable for unit test
          filter.keys.sort_by { |symbol| "***REMOVED***{symbol}" }.each do |attr|
            filters << Net::LDAP::Filter.eq("***REMOVED***{attr}", "***REMOVED***{filter[attr]}")
          end
          combine_filters(filters, "&")
        end
        
        ***REMOVED******REMOVED***
        ***REMOVED*** Returns +Array+ of object classes making up this type of LDAP entity.
        def object_classes
          @object_classes ||= UCB::LDAP::Schema.schema_hash[entity_name]["objectClasses"]
        end
        
        def unique_object_class
          @unique_object_class ||= UCB::LDAP::Schema.schema_hash[entity_name]["uniqueObjectClass"]
        end
        
        ***REMOVED******REMOVED***
        ***REMOVED*** returns an Array of symbols where each symbol is the name of
        ***REMOVED*** a required attribute for the Entry
        def required_attributes
          required_schema_attributes.keys
        end
        
        ***REMOVED******REMOVED***
        ***REMOVED*** returns Hash of SchemaAttribute objects that are required
        ***REMOVED*** for the Entry.  Each SchemaAttribute object is keyed to the
        ***REMOVED*** attribute's name.
        ***REMOVED***
        ***REMOVED*** Note: required_schema_attributes will not return aliases, it
        ***REMOVED*** only returns the original attributes
        ***REMOVED***
        ***REMOVED*** Example:
        ***REMOVED***  Person.required_schema_attribues[:cn]
        ***REMOVED***  => <UCB::LDAP::Schema::Attribute:0x11c6b68>
        ***REMOVED***
        def required_schema_attributes
          required_atts = schema_attributes_hash.reject { |key, value| !value.required? }
          required_atts.reject do |key, value|
            aliases = value.aliases.map { |a| canonical(a) }
            aliases.include?(key)
          end
        end

        ***REMOVED******REMOVED***
        ***REMOVED*** Returns an +Array+ of Schema::Attribute for the entity.
        ***REMOVED***
        def schema_attributes_array
          @schema_attributes_array || set_schema_attributes
          @schema_attributes_array
        end

        ***REMOVED******REMOVED***
        ***REMOVED*** Returns as +Hash+ whose keys are the canonical attribute names
        ***REMOVED*** and whose values are the corresponding Schema::Attributes.
        ***REMOVED***
        def schema_attributes_hash
          @schema_attributes_hash || set_schema_attributes
          @schema_attributes_hash
        end
        
        def schema_attribute(attribute_name)
          schema_attributes_hash[canonical(attribute_name)] ||
            raise(BadAttributeNameException, "'***REMOVED***{attribute_name}' is not a recognized attribute name")
        end

        ***REMOVED******REMOVED***
        ***REMOVED*** Returns Array of UCB::LDAP::Entry for entries matching _args_.
        ***REMOVED*** When called from a subclass, returns Array of subclass instances.
        ***REMOVED***
        ***REMOVED*** See Net::LDAP::search for more information on _args_.
        ***REMOVED***
        ***REMOVED*** Most common arguments are <tt>:base</tt> and <tt>:filter</tt>.
        ***REMOVED*** Search methods of subclasses have default <tt>:base</tt> that
        ***REMOVED*** can be overriden.
        ***REMOVED*** 
        ***REMOVED*** See make_search_filter for <tt>:filter</tt> options.
        ***REMOVED*** 
        ***REMOVED***   base = "ou=people,dc=berkeley,dc=edu"
        ***REMOVED***   entries = UCB::LDAP::Entry.search(:base => base, :filter => {:uid => '123'})
        ***REMOVED***   entries = UCB::LDAP::Entry.search(:base => base, :filter => {:sn => 'Doe', :givenname => 'John'}
        ***REMOVED***
        def search(args={})
          args = args.dup
          args[:base] ||= tree_base
          args[:filter] = make_search_filter args[:filter] if args[:filter]
          
          results = []
          net_ldap.search(args) do |entry|
            results << new(entry)
          end
          results
        end

        ***REMOVED******REMOVED***
        ***REMOVED*** Returns the canonical representation of a symbol or string so
        ***REMOVED*** we can look up attributes in a number of ways.
        ***REMOVED***
        def canonical(string_or_symbol)
          string_or_symbol.to_s.downcase.to_sym
        end
        
        ***REMOVED******REMOVED***
        ***REMOVED*** Returns underlying Net::LDAP instance.
        ***REMOVED***
        def net_ldap ***REMOVED***:nodoc:
          UCB::LDAP.net_ldap
        end

        private unless $TESTING
        
        ***REMOVED******REMOVED***
        ***REMOVED*** Schema entity name.  Set in each subclass.
        ***REMOVED***
        def entity_name
          @entity_name
        end
        
        ***REMOVED******REMOVED***
        ***REMOVED*** Want an array of Schema::Attributes as well as a hash
        ***REMOVED*** of all possible variations on a name pointing to correct array element.
        ***REMOVED***
        def set_schema_attributes
          @schema_attributes_array = []
          @schema_attributes_hash = {}
          UCB::LDAP::Schema.schema_hash[entity_name]["attributes"].each do |k, v|
            sa = UCB::LDAP::Schema::Attribute.new(v.merge("name" => k))
            @schema_attributes_array << sa
            [sa.name, sa.aliases].flatten.each do |name|
              @schema_attributes_hash[canonical(name)] = sa
            end
          end
        rescue
          raise "Error loading schema attributes for entity_name '***REMOVED***{entity_name}'"
        end
        
        ***REMOVED******REMOVED***
        ***REMOVED*** Returns tree base for LDAP searches.  Subclasses each have
        ***REMOVED*** their own value.
        ***REMOVED*** 
        ***REMOVED*** Can be overridden in ***REMOVED***search by passing in a <tt>:base</tt> parm.
        ***REMOVED******REMOVED***
        def tree_base
          @tree_base
        end
        
        def tree_base=(tree_base)
          @tree_base = tree_base
        end
        
      end  ***REMOVED*** end of class methods
    end
  end 
end
