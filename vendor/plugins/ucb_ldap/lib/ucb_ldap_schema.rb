***REMOVED***require 'open-uri'
***REMOVED***require 'net/http'
require 'yaml'
require 'net/https'

module UCB ***REMOVED***:nodoc:
  module LDAP
    ***REMOVED*** = UCB::LDAP::Schema
    ***REMOVED***
    ***REMOVED*** Class responsible for getting schema information for all of the UCB::LDAP
    ***REMOVED*** entities.  Attributes are modeled as instances of UCB::LDAP::Schema::Attribute.
    ***REMOVED***
    ***REMOVED*** Each entity (Person, Org, etc.) has a Hash of attributes where the keys are
    ***REMOVED*** canonical (see Entry.canonical) attribute/alias names 
    ***REMOVED*** and the values are Schema::Attribute's.
    ***REMOVED***
    ***REMOVED*** You don't have to explicitly load schema information; the UCB::LDAP module
    ***REMOVED*** loads schema information as needed.  Unless you want to override the schema
    ***REMOVED*** url (or file) you probably won't need to work directly with this class.
    ***REMOVED***
    ***REMOVED*** == Schema Source
    ***REMOVED***
    ***REMOVED*** Schema information is loaded from a url defined by the 
    ***REMOVED*** SCHEMA_* constants.  A version of the file is distributed
    ***REMOVED*** with this Gem and is used in case the web version is not accessible.
    ***REMOVED***
    module Schema
    
      SCHEMA_BASE_URL = 'calnet.berkeley.edu'
      SCHEMA_CONTENT_PATH = '/developers/developerResources/yaml/schema/schema.yaml'
      SCHEMA_FILE = "***REMOVED***{File.dirname(__FILE__)}/../schema/schema.yml"
      
      class << self
      
        ***REMOVED*** Returns a hash of all attributes for all entities.  Keys are 
        ***REMOVED*** entity names, values hash of attributes for given entity.
        def schema_hash()
          @schema_hash ||= load_attributes
        end
        
        ***REMOVED*** Returns schema base url.  Defaults to SCHEMA_BASE_URL constant.
        def schema_base_url()
          @schema_base_url || SCHEMA_BASE_URL
        end
        
        ***REMOVED*** Setter for schema_base_url().  Use this to override url of LDAP
        ***REMOVED*** schema information.
        def schema_base_url=(base_url)
          @schema_base_url = base_url
        end
        
        ***REMOVED*** Returns schema content path.  Defaults to SCHEMA_CONTENT_PATH constant.
        def schema_content_path()
          @schema_content_path || SCHEMA_CONTENT_PATH
        end
        
        ***REMOVED*** Setter for schema_content_path().  Use this to override content path of LDAP
        ***REMOVED*** schema information.
        def schema_content_path=(content_path)
          @schema_content_path = content_path
        end
        
        ***REMOVED*** Returns schema file.  Defaults fo SCHEMA_FILE constant.
        def schema_file()
          @schema_file || SCHEMA_FILE
        end
        
        ***REMOVED*** Setter for schema_file().  Use this to override location of
        ***REMOVED*** local schema file.
        def schema_file=(file)
          @schema_file = file
        end
        
      ***REMOVED***private unless $TESTING
        
        ***REMOVED*** Setter for schema_hash()
        def schema_hash=(h) ***REMOVED***:nodoc:
          @schema_hash = h
        end
        
        ***REMOVED*** Load attributes from URL or file
        def load_attributes ***REMOVED***:nodoc:
          load_attributes_from_url
        rescue
          puts "Warning: schema loading from file"
          load_attributes_from_file
        end
        
        def load_attributes_from_url() ***REMOVED***:nodoc:
          self.schema_hash = YAML.load(yaml_from_url)
        end
        
        def yaml_from_url() ***REMOVED***:nodoc:
          http = Net::HTTP.new(SCHEMA_BASE_URL, 443)
          http.use_ssl = true
          http.get(SCHEMA_CONTENT_PATH).body
        end
        
        def load_attributes_from_file() ***REMOVED***:nodoc:
          self.schema_hash = YAML.load(yaml_from_file)
        end

        def yaml_from_file ***REMOVED***:nodoc:
          IO.read(schema_file)
        end
        
        ***REMOVED*** Get instance variable w/o loading -- for testing purposes.
        def schema_hash_i() ***REMOVED***:nodoc:
          @schema_hash
        end
        
      end
    end
  end
end
