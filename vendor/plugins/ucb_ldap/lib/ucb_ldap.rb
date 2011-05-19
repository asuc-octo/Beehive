require 'rubygems'
require 'net/ldap'
require 'time'
require 'ucb_ldap_exceptions'
require 'ucb_ldap_schema'
require 'ucb_ldap_schema_attribute'
require 'ucb_ldap_entry'

require 'person/affiliation_methods.rb'
require 'person/generic_attributes.rb'
require 'ucb_ldap_person.rb'

require 'ucb_ldap_person_job_appointment'
require 'ucb_ldap_org'
require 'ucb_ldap_namespace'
require 'ucb_ldap_address'
require 'ucb_ldap_student_term'
require 'ucb_ldap_affiliation'
require 'ucb_ldap_service'

module UCB ***REMOVED***:nodoc:
  ***REMOVED******REMOVED***
  ***REMOVED*** =UCB::LDAP
  ***REMOVED***
  ***REMOVED*** <b>If you are doing searches that don't require a privileged bind
  ***REMOVED*** and are accessing the default (production) server
  ***REMOVED*** you probably don't need to call any of the methods in this module.</b>
  ***REMOVED*** 
  ***REMOVED*** Methods in this module are about making <em>connections</em>
  ***REMOVED*** to the LDAP directory.
  ***REMOVED*** 
  ***REMOVED*** Interaction with the directory (searches and updates) is usually through the search()
  ***REMOVED*** and other methods of UCB::LDAP::Entry and its sub-classes.
  ***REMOVED*** 
  module LDAP

    HOST_PRODUCTION = 'ldap.berkeley.edu'
    HOST_TEST       = 'ldap-test.berkeley.edu'
    
    class << self
      ***REMOVED******REMOVED***
      ***REMOVED*** Give (new) bind credentials to LDAP.  An attempt will be made
      ***REMOVED*** to bind and will raise BindFailedException if bind fails.
      ***REMOVED*** 
      ***REMOVED*** Call clear_authentication() to remove privileged bind.
      ***REMOVED***
      def authenticate(username, password)
        @username, @password = username, password
        new_net_ldap() ***REMOVED*** to force bind()
      end
      
      ***REMOVED******REMOVED***
      ***REMOVED*** Removes current bind (username, password).
      ***REMOVED***
      def clear_authentication()
        authenticate(nil, nil)
      end

      ***REMOVED******REMOVED***
      ***REMOVED*** Returns LDAP host used for lookups.  Default is HOST_PRODUCTION.
      ***REMOVED***
      def host()
        @host || HOST_PRODUCTION
      end
      
      ***REMOVED******REMOVED***
      ***REMOVED*** Setter for ***REMOVED***host.
      ***REMOVED*** 
      ***REMOVED*** Note: validation of host is deferred until a search is performed
      ***REMOVED*** or ***REMOVED***authenticate() is called at which time a bad host will
      ***REMOVED*** raise ConnectionFailedException.
      ***REMOVED***---
      ***REMOVED*** Don't want to reconnect unless host really changed.
      ***REMOVED***
      def host=(host)
        if host != @host
          @host = host
          @net_ldap = nil
        end
      end
      
      ***REMOVED******REMOVED***
      ***REMOVED*** Returns Net::LDAP instance that is used by UCB::LDAP::Entry
      ***REMOVED*** and subclasses for directory searches.
      ***REMOVED***
      ***REMOVED*** You might need this to perform searches not supported by 
      ***REMOVED*** sub-classes of Entry.
      ***REMOVED***
      ***REMOVED*** Note: callers should not cache the results of this call unless they
      ***REMOVED*** are prepared to handle timed-out connections (which this method does).
      ***REMOVED***
      def net_ldap()
        @net_ldap ||= new_net_ldap
      end

      def password() ***REMOVED***:nodoc:
        @password
      end
      
      def username() ***REMOVED***:nodoc:
        @username
      end

      ***REMOVED******REMOVED***
      ***REMOVED*** If you are using UCB::LDAP in a Rails application you can specify binds on a
      ***REMOVED*** per-environment basis, just as you can with database credentials.
      ***REMOVED***
      ***REMOVED***   ***REMOVED*** in ../config/ldap.yml
      ***REMOVED***   
      ***REMOVED***   ***REMOVED***
      ***REMOVED***     username: user_dev
      ***REMOVED***     password: pass_dev
      ***REMOVED***   
      ***REMOVED***   ***REMOVED*** etc.
      ***REMOVED***
      ***REMOVED*** 
      ***REMOVED***   ***REMOVED*** in ../config/environment.rb
      ***REMOVED***
      ***REMOVED***   require 'ucb_ldap'
      ***REMOVED***   UCB::LDAP.bind_for_rails()
      ***REMOVED*** 
      ***REMOVED*** Runtime error will be raised if bind_file not found or if environment key not
      ***REMOVED*** found in bind_file.
      ***REMOVED***
      def bind_for_rails(bind_file = "***REMOVED***{Rails.root}/config/ldap.yml", environment = RAILS_ENV)
        bind(bind_file, environment)
      end
      
      def bind(bind_file, environment)
        raise "Can't find bind file: ***REMOVED***{bind_file}" unless FileTest.exists?(bind_file)
        binds = YAML.load(IO.read(bind_file))
        bind = binds[environment] || raise("Can't find environment=***REMOVED***{environment} in bind file")
        authenticate(bind['username'], bind['password'])
      end
      
      ***REMOVED******REMOVED***
      ***REMOVED*** Returns +arg+ as a Ruby +Date+ in local time zone.  Returns +nil+ if +arg+ is +nil+.
      ***REMOVED***
      def local_date_parse(arg)        
        arg.nil? ? nil : Date.parse(Time.parse(arg.to_s).localtime.to_s)
      end
      
      ***REMOVED******REMOVED***
      ***REMOVED*** Returns +arg+ as a Ruby +DateTime+ in local time zone.  Returns +nil+ if +arg+ is +nil+.
      ***REMOVED***
      def local_datetime_parse(arg)        
        arg.nil? ? nil : DateTime.parse(Time.parse(arg.to_s).localtime.to_s)
      end
  
    private unless $TESTING

      ***REMOVED******REMOVED***
      ***REMOVED*** The value of the :auth parameter for Net::LDAP.new().
      ***REMOVED***
      def authentication_information()
        password.nil? ? 
          {:method => :anonymous} : 
          {:method => :simple, :username => username, :password => password}
      end

      ***REMOVED******REMOVED***
      ***REMOVED*** Returns +true+ if connection simple search works.
      ***REMOVED***
      def ldap_ping()
        search_attrs = {
          :base => "",
          :scope => Net::LDAP::SearchScope_BaseObject,
          :attributes => [1.1]
        }
        result = false
        @net_ldap.search(search_attrs) { result = true }
        result
      end

      ***REMOVED******REMOVED***
      ***REMOVED*** Returns new Net::LDAP instance.
      ***REMOVED***
      def new_net_ldap()
        params = {
          :host => host,
          :auth => authentication_information,
          :port => 636, 
          :encryption => {:method =>:simple_tls}
        }
        @net_ldap = Net::LDAP.new(params)
        @net_ldap.bind || raise(BindFailedException)
        @net_ldap
      rescue Net::LDAP::LdapError => e
        raise(BindFailedException)
      end

      ***REMOVED******REMOVED***
      ***REMOVED*** Used for testing
      ***REMOVED***
      def clear_instance_variables()
        @host = nil
        @net_ldap = nil
        @username = nil
        @password = nil
      end
    end
  end
end

