
module UCB
  module LDAP
    module Schema
      ***REMOVED*** = UCB::LDAP::SchemaAttribute
      ***REMOVED*** 
      ***REMOVED*** This class models <em>schema</em> information about an LDAP attribute.
      ***REMOVED*** 
      ***REMOVED*** This class is used internally by various UCB::LDAP classes.
      ***REMOVED*** Users of UCB::LDAP probably won't need to interact with this
      ***REMOVED*** class directly.
      ***REMOVED***
      ***REMOVED*** The LDAP entity classes have access to their Attribute's.
      ***REMOVED***
      ***REMOVED***   uid_attr = UCB::LDAP::Person.attribute(:uid) ***REMOVED*** :symbol ok as attribute name
      ***REMOVED***
      ***REMOVED***   uid_attr.name             ***REMOVED***=> 'uid'
      ***REMOVED***   uid_attr.aliases          ***REMOVED***=> ['userid']
      ***REMOVED***   uid_attr.description      ***REMOVED***=> 'Standard LDAP attribute type'
      ***REMOVED***   uid_attr.multi_valued?    ***REMOVED***=> true
      ***REMOVED***   uid_attr.required?        ***REMOVED***=> true
      ***REMOVED***   uid_attr.type             ***REMOVED***=> 'string'
      ***REMOVED***
      ***REMOVED***   uas_attr = UCB::LDAP::Person.attribute('berkeleyEduUasEligFlag') ***REMOVED*** case doesn't matter
      ***REMOVED***
      ***REMOVED***   uas_attr.name             ***REMOVED***=> 'berkeleyEduUasEligFlag'
      ***REMOVED***   uas_attr.aliases          ***REMOVED***=> ['ucbvalidflag']
      ***REMOVED***   uas_attr.description      ***REMOVED***=> 'UAS Eligibility Flag'
      ***REMOVED***   uas_attr.multi_valued?    ***REMOVED***=> false
      ***REMOVED***   uas_attr.required?        ***REMOVED***=> false
      ***REMOVED***   uas_attr.type             ***REMOVED***=> 'boolean'
      ***REMOVED***
      class Attribute
      
        ***REMOVED*** Constructor called by UCB::LDAP::Entry.set_schema_attributes().
        def initialize(args) ***REMOVED***:nodoc:
          @name = args["name"]
          @type = args["syntax"]
          @aliases = args["aliases"] || []
          @description = args["description"]
          @required = args["required"]
          @multi_valued = args["multi"]
        end
        
        ***REMOVED*** Returns attribute name as found in the schema 
        def name
          @name
        end
        
        ***REMOVED*** Returns Array of aliases as found in schema.  Returns empty
        ***REMOVED*** Array ([]) if no aliases.
        ***REMOVED***
        def aliases
          @aliases
        end
        
        ***REMOVED*** Returns (data) type.  Used by get_value() to cast value to correct Ruby type.
        ***REMOVED***
        ***REMOVED*** Supported types and corresponding Ruby type:
        ***REMOVED***
        ***REMOVED***   * string      String
        ***REMOVED***   * integer     Fixnum
        ***REMOVED***   * boolean     TrueClass / FalseClass
        ***REMOVED***   * timestamp   DateTime (convenience methods may return Date if attribute's semantics don't include time)
        ***REMOVED***
        def type
          @type
        end
        
        ***REMOVED*** Returns attribute description.  Of limited value since all
        ***REMOVED*** standard LDAP attributes have a description of 
        ***REMOVED*** "Standard LDAP attribute type".
        def description
          @description
        end
        
        ***REMOVED*** Returns <tt>true</tt> if attribute is required, else <tt>false</tt>
        def required?
          @required
        end
        
        ***REMOVED*** Returns <tt>true</tt> if attribute is multi-valued, else <tt>false</tt>.
        ***REMOVED*** Multi-valued attribute values are returned as an Array.
        def multi_valued?
          @multi_valued
        end
        
        ***REMOVED*** Takes a value returned from an LDAP attribute (+Array+ of +String+)
        ***REMOVED*** and returns value with correct cardinality (array or scalar)
        ***REMOVED*** cast to correct ***REMOVED***type.
        def get_value(array)
          if array.nil?
            return false if boolean?
            return [] if multi_valued?
            return nil
          end
          typed_array = apply_type_to_array(array)
          multi_valued? ? typed_array : typed_array.first
        end
        
        ***REMOVED*** Cast each element to correct type.
        def apply_type_to_array(array) ***REMOVED***:nodoc:
          array.map{|scalar| apply_type_to_scalar scalar}
        end
        
        ***REMOVED*** Case element to correct type
        def apply_type_to_scalar(string) ***REMOVED***:nodoc:
          return string if string?
          return string.to_i if integer?
          return %w{true 1}.include?(string) ? true : false if boolean?
          return UCB::LDAP.local_datetime_parse(string) if timestamp?
          raise "unknown type '***REMOVED***{type}' for attribute '***REMOVED***{name}'"
        end
        
        ***REMOVED*** Return <tt>true</tt> if attribute type is string.
        def string?
          type == "string"
        end
        
        ***REMOVED*** Return <tt>true</tt> if attribute type is integer.
        def integer?
          type == "integer"
        end
        
        ***REMOVED*** Return <tt>true</tt> if attribute type is boolean.
        def boolean?
          type == "boolean"
        end
        
        ***REMOVED*** Return <tt>true</tt> if attribute type is timestamp
        def timestamp?
          type == "timestamp" 
        end
        
        ***REMOVED*** Returns a value in LDAP attribute value format (+Array+ of +String+).
        def ldap_value(value)
          return nil if value.nil?
          return value.map{|v| ldap_value_stripped(v)} if value.instance_of?(Array)
          return [ldap_value_stripped(value)]
        end
        
        private 
        
        ***REMOVED*** Remove leading/trailing white-space and imbedded newlines.
        def ldap_value_stripped(s)
          s.to_s.strip.gsub(/\n/,"")
        end
        
      end
      
    end
  end 
end
