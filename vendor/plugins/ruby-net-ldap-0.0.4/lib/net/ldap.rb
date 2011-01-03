***REMOVED*** $Id: ldap.rb 154 2006-08-15 09:35:43Z blackhedd $
***REMOVED***
***REMOVED*** Net::LDAP for Ruby
***REMOVED***
***REMOVED***
***REMOVED*** Copyright (C) 2006 by Francis Cianfrocca. All Rights Reserved.
***REMOVED***
***REMOVED*** Written and maintained by Francis Cianfrocca, gmail: garbagecat10.
***REMOVED***
***REMOVED*** This program is free software.
***REMOVED*** You may re-distribute and/or modify this program under the same terms
***REMOVED*** as Ruby itself: Ruby Distribution License or GNU General Public License.
***REMOVED***
***REMOVED***
***REMOVED*** See Net::LDAP for documentation and usage samples.
***REMOVED***


require 'socket'
require 'ostruct'

begin
  require 'openssl'
  $net_ldap_openssl_available = true
rescue LoadError
end

require 'net/ber'
require 'net/ldap/pdu'
require 'net/ldap/filter'
require 'net/ldap/dataset'
require 'net/ldap/psw'
require 'net/ldap/entry'


module Net


  ***REMOVED*** == Net::LDAP
  ***REMOVED***
  ***REMOVED*** This library provides a pure-Ruby implementation of the
  ***REMOVED*** LDAP client protocol, per RFC-2251.
  ***REMOVED*** It can be used to access any server which implements the
  ***REMOVED*** LDAP protocol.
  ***REMOVED***
  ***REMOVED*** Net::LDAP is intended to provide full LDAP functionality
  ***REMOVED*** while hiding the more arcane aspects
  ***REMOVED*** the LDAP protocol itself, and thus presenting as Ruby-like
  ***REMOVED*** a programming interface as possible.
  ***REMOVED*** 
  ***REMOVED*** == Quick-start for the Impatient
  ***REMOVED*** === Quick Example of a user-authentication against an LDAP directory:
  ***REMOVED***
  ***REMOVED***  require 'rubygems'
  ***REMOVED***  require 'net/ldap'
  ***REMOVED***  
  ***REMOVED***  ldap = Net::LDAP.new
  ***REMOVED***  ldap.host = your_server_ip_address
  ***REMOVED***  ldap.port = 389
  ***REMOVED***  ldap.auth "joe_user", "opensesame"
  ***REMOVED***  if ldap.bind
  ***REMOVED***    ***REMOVED*** authentication succeeded
  ***REMOVED***  else
  ***REMOVED***    ***REMOVED*** authentication failed
  ***REMOVED***  end
  ***REMOVED***
  ***REMOVED***
  ***REMOVED*** === Quick Example of a search against an LDAP directory:
  ***REMOVED***
  ***REMOVED***  require 'rubygems'
  ***REMOVED***  require 'net/ldap'
  ***REMOVED***  
  ***REMOVED***  ldap = Net::LDAP.new :host => server_ip_address,
  ***REMOVED***       :port => 389,
  ***REMOVED***       :auth => {
  ***REMOVED***             :method => :simple,
  ***REMOVED***             :username => "cn=manager,dc=example,dc=com",
  ***REMOVED***             :password => "opensesame"
  ***REMOVED***       }
  ***REMOVED***
  ***REMOVED***  filter = Net::LDAP::Filter.eq( "cn", "George*" )
  ***REMOVED***  treebase = "dc=example,dc=com"
  ***REMOVED***  
  ***REMOVED***  ldap.search( :base => treebase, :filter => filter ) do |entry|
  ***REMOVED***    puts "DN: ***REMOVED***{entry.dn}"
  ***REMOVED***    entry.each do |attribute, values|
  ***REMOVED***      puts "   ***REMOVED***{attribute}:"
  ***REMOVED***      values.each do |value|
  ***REMOVED***        puts "      --->***REMOVED***{value}"
  ***REMOVED***      end
  ***REMOVED***    end
  ***REMOVED***  end
  ***REMOVED***  
  ***REMOVED***  p ldap.get_operation_result
  ***REMOVED***  
  ***REMOVED***
  ***REMOVED*** == A Brief Introduction to LDAP
  ***REMOVED***
  ***REMOVED*** We're going to provide a quick, informal introduction to LDAP
  ***REMOVED*** terminology and
  ***REMOVED*** typical operations. If you're comfortable with this material, skip
  ***REMOVED*** ahead to "How to use Net::LDAP." If you want a more rigorous treatment
  ***REMOVED*** of this material, we recommend you start with the various IETF and ITU
  ***REMOVED*** standards that relate to LDAP.
  ***REMOVED***
  ***REMOVED*** === Entities
  ***REMOVED*** LDAP is an Internet-standard protocol used to access directory servers.
  ***REMOVED*** The basic search unit is the <i>entity,</i> which corresponds to
  ***REMOVED*** a person or other domain-specific object.
  ***REMOVED*** A directory service which supports the LDAP protocol typically
  ***REMOVED*** stores information about a number of entities.
  ***REMOVED***
  ***REMOVED*** === Principals
  ***REMOVED*** LDAP servers are typically used to access information about people,
  ***REMOVED*** but also very often about such items as printers, computers, and other
  ***REMOVED*** resources. To reflect this, LDAP uses the term <i>entity,</i> or less
  ***REMOVED*** commonly, <i>principal,</i> to denote its basic data-storage unit.
  ***REMOVED*** 
  ***REMOVED***
  ***REMOVED*** === Distinguished Names
  ***REMOVED*** In LDAP's view of the world,
  ***REMOVED*** an entity is uniquely identified by a globally-unique text string
  ***REMOVED*** called a <i>Distinguished Name,</i> originally defined in the X.400
  ***REMOVED*** standards from which LDAP is ultimately derived.
  ***REMOVED*** Much like a DNS hostname, a DN is a "flattened" text representation
  ***REMOVED*** of a string of tree nodes. Also like DNS (and unlike Java package
  ***REMOVED*** names), a DN expresses a chain of tree-nodes written from left to right
  ***REMOVED*** in order from the most-resolved node to the most-general one.
  ***REMOVED***
  ***REMOVED*** If you know the DN of a person or other entity, then you can query
  ***REMOVED*** an LDAP-enabled directory for information (attributes) about the entity.
  ***REMOVED*** Alternatively, you can query the directory for a list of DNs matching
  ***REMOVED*** a set of criteria that you supply.
  ***REMOVED***
  ***REMOVED*** === Attributes
  ***REMOVED***
  ***REMOVED*** In the LDAP view of the world, a DN uniquely identifies an entity.
  ***REMOVED*** Information about the entity is stored as a set of <i>Attributes.</i>
  ***REMOVED*** An attribute is a text string which is associated with zero or more
  ***REMOVED*** values. Most LDAP-enabled directories store a well-standardized
  ***REMOVED*** range of attributes, and constrain their values according to standard
  ***REMOVED*** rules.
  ***REMOVED***
  ***REMOVED*** A good example of an attribute is <tt>sn,</tt> which stands for "Surname."
  ***REMOVED*** This attribute is generally used to store a person's surname, or last name.
  ***REMOVED*** Most directories enforce the standard convention that
  ***REMOVED*** an entity's <tt>sn</tt> attribute have <i>exactly one</i> value. In LDAP
  ***REMOVED*** jargon, that means that <tt>sn</tt> must be <i>present</i> and
  ***REMOVED*** <i>single-valued.</i>
  ***REMOVED***
  ***REMOVED*** Another attribute is <tt>mail,</tt> which is used to store email addresses.
  ***REMOVED*** (No, there is no attribute called "email," perhaps because X.400 terminology
  ***REMOVED*** predates the invention of the term <i>email.</i>) <tt>mail</tt> differs
  ***REMOVED*** from <tt>sn</tt> in that most directories permit any number of values for the
  ***REMOVED*** <tt>mail</tt> attribute, including zero.
  ***REMOVED***
  ***REMOVED***
  ***REMOVED*** === Tree-Base
  ***REMOVED*** We said above that X.400 Distinguished Names are <i>globally unique.</i>
  ***REMOVED*** In a manner reminiscent of DNS, LDAP supposes that each directory server
  ***REMOVED*** contains authoritative attribute data for a set of DNs corresponding
  ***REMOVED*** to a specific sub-tree of the (notional) global directory tree.
  ***REMOVED*** This subtree is generally configured into a directory server when it is
  ***REMOVED*** created. It matters for this discussion because most servers will not
  ***REMOVED*** allow you to query them unless you specify a correct tree-base.
  ***REMOVED***
  ***REMOVED*** Let's say you work for the engineering department of Big Company, Inc.,
  ***REMOVED*** whose internet domain is bigcompany.com. You may find that your departmental
  ***REMOVED*** directory is stored in a server with a defined tree-base of
  ***REMOVED***  ou=engineering,dc=bigcompany,dc=com
  ***REMOVED*** You will need to supply this string as the <i>tree-base</i> when querying this
  ***REMOVED*** directory. (Ou is a very old X.400 term meaning "organizational unit."
  ***REMOVED*** Dc is a more recent term meaning "domain component.")
  ***REMOVED***
  ***REMOVED*** === LDAP Versions
  ***REMOVED*** (stub, discuss v2 and v3)
  ***REMOVED***
  ***REMOVED*** === LDAP Operations
  ***REMOVED*** The essential operations are: ***REMOVED***bind, ***REMOVED***search, ***REMOVED***add, ***REMOVED***modify, ***REMOVED***delete, and ***REMOVED***rename.
  ***REMOVED*** ==== Bind
  ***REMOVED*** ***REMOVED***bind supplies a user's authentication credentials to a server, which in turn verifies
  ***REMOVED*** or rejects them. There is a range of possibilities for credentials, but most directories
  ***REMOVED*** support a simple username and password authentication.
  ***REMOVED***
  ***REMOVED*** Taken by itself, ***REMOVED***bind can be used to authenticate a user against information
  ***REMOVED*** stored in a directory, for example to permit or deny access to some other resource.
  ***REMOVED*** In terms of the other LDAP operations, most directories require a successful ***REMOVED***bind to
  ***REMOVED*** be performed before the other operations will be permitted. Some servers permit certain
  ***REMOVED*** operations to be performed with an "anonymous" binding, meaning that no credentials are
  ***REMOVED*** presented by the user. (We're glossing over a lot of platform-specific detail here.)
  ***REMOVED***
  ***REMOVED*** ==== Search
  ***REMOVED*** Calling ***REMOVED***search against the directory involves specifying a treebase, a set of <i>search filters,</i>
  ***REMOVED*** and a list of attribute values.
  ***REMOVED*** The filters specify ranges of possible values for particular attributes. Multiple
  ***REMOVED*** filters can be joined together with AND, OR, and NOT operators.
  ***REMOVED*** A server will respond to a ***REMOVED***search by returning a list of matching DNs together with a
  ***REMOVED*** set of attribute values for each entity, depending on what attributes the search requested.
  ***REMOVED*** 
  ***REMOVED*** ==== Add
  ***REMOVED*** ***REMOVED***add specifies a new DN and an initial set of attribute values. If the operation
  ***REMOVED*** succeeds, a new entity with the corresponding DN and attributes is added to the directory.
  ***REMOVED***
  ***REMOVED*** ==== Modify
  ***REMOVED*** ***REMOVED***modify specifies an entity DN, and a list of attribute operations. ***REMOVED***modify is used to change
  ***REMOVED*** the attribute values stored in the directory for a particular entity.
  ***REMOVED*** ***REMOVED***modify may add or delete attributes (which are lists of values) or it change attributes by
  ***REMOVED*** adding to or deleting from their values.
  ***REMOVED*** Net::LDAP provides three easier methods to modify an entry's attribute values:
  ***REMOVED*** ***REMOVED***add_attribute, ***REMOVED***replace_attribute, and ***REMOVED***delete_attribute.
  ***REMOVED***
  ***REMOVED*** ==== Delete
  ***REMOVED*** ***REMOVED***delete specifies an entity DN. If it succeeds, the entity and all its attributes
  ***REMOVED*** is removed from the directory.
  ***REMOVED***
  ***REMOVED*** ==== Rename (or Modify RDN)
  ***REMOVED*** ***REMOVED***rename (or ***REMOVED***modify_rdn) is an operation added to version 3 of the LDAP protocol. It responds to
  ***REMOVED*** the often-arising need to change the DN of an entity without discarding its attribute values.
  ***REMOVED*** In earlier LDAP versions, the only way to do this was to delete the whole entity and add it
  ***REMOVED*** again with a different DN.
  ***REMOVED***
  ***REMOVED*** ***REMOVED***rename works by taking an "old" DN (the one to change) and a "new RDN," which is the left-most
  ***REMOVED*** part of the DN string. If successful, ***REMOVED***rename changes the entity DN so that its left-most
  ***REMOVED*** node corresponds to the new RDN given in the request. (RDN, or "relative distinguished name,"
  ***REMOVED*** denotes a single tree-node as expressed in a DN, which is a chain of tree nodes.)
  ***REMOVED***
  ***REMOVED*** == How to use Net::LDAP
  ***REMOVED***
  ***REMOVED*** To access Net::LDAP functionality in your Ruby programs, start by requiring
  ***REMOVED*** the library:
  ***REMOVED***
  ***REMOVED***  require 'net/ldap'
  ***REMOVED***
  ***REMOVED*** If you installed the Gem version of Net::LDAP, and depending on your version of
  ***REMOVED*** Ruby and rubygems, you _may_ also need to require rubygems explicitly:
  ***REMOVED***
  ***REMOVED***  require 'rubygems'
  ***REMOVED***  require 'net/ldap'
  ***REMOVED***
  ***REMOVED*** Most operations with Net::LDAP start by instantiating a Net::LDAP object.
  ***REMOVED*** The constructor for this object takes arguments specifying the network location
  ***REMOVED*** (address and port) of the LDAP server, and also the binding (authentication)
  ***REMOVED*** credentials, typically a username and password.
  ***REMOVED*** Given an object of class Net:LDAP, you can then perform LDAP operations by calling
  ***REMOVED*** instance methods on the object. These are documented with usage examples below.
  ***REMOVED***
  ***REMOVED*** The Net::LDAP library is designed to be very disciplined about how it makes network
  ***REMOVED*** connections to servers. This is different from many of the standard native-code
  ***REMOVED*** libraries that are provided on most platforms, which share bloodlines with the
  ***REMOVED*** original Netscape/Michigan LDAP client implementations. These libraries sought to
  ***REMOVED*** insulate user code from the workings of the network. This is a good idea of course,
  ***REMOVED*** but the practical effect has been confusing and many difficult bugs have been caused
  ***REMOVED*** by the opacity of the native libraries, and their variable behavior across platforms.
  ***REMOVED***
  ***REMOVED*** In general, Net::LDAP instance methods which invoke server operations make a connection
  ***REMOVED*** to the server when the method is called. They execute the operation (typically binding first)
  ***REMOVED*** and then disconnect from the server. The exception is Net::LDAP***REMOVED***open, which makes a connection
  ***REMOVED*** to the server and then keeps it open while it executes a user-supplied block. Net::LDAP***REMOVED***open
  ***REMOVED*** closes the connection on completion of the block.
  ***REMOVED***

  class LDAP

    class LdapError < Exception; end

    VERSION = "0.0.4"


    SearchScope_BaseObject = 0
    SearchScope_SingleLevel = 1
    SearchScope_WholeSubtree = 2
    SearchScopes = [SearchScope_BaseObject, SearchScope_SingleLevel, SearchScope_WholeSubtree]

    AsnSyntax = {
      :application => {
        :constructed => {
          0 => :array,              ***REMOVED*** BindRequest
          1 => :array,              ***REMOVED*** BindResponse
          2 => :array,              ***REMOVED*** UnbindRequest
          3 => :array,              ***REMOVED*** SearchRequest
          4 => :array,              ***REMOVED*** SearchData
          5 => :array,              ***REMOVED*** SearchResult
          6 => :array,              ***REMOVED*** ModifyRequest
          7 => :array,              ***REMOVED*** ModifyResponse
          8 => :array,              ***REMOVED*** AddRequest
          9 => :array,              ***REMOVED*** AddResponse
          10 => :array,             ***REMOVED*** DelRequest
          11 => :array,             ***REMOVED*** DelResponse
          12 => :array,             ***REMOVED*** ModifyRdnRequest
          13 => :array,             ***REMOVED*** ModifyRdnResponse
          14 => :array,             ***REMOVED*** CompareRequest
          15 => :array,             ***REMOVED*** CompareResponse
          16 => :array,             ***REMOVED*** AbandonRequest
          19 => :array,             ***REMOVED*** SearchResultReferral
          24 => :array,             ***REMOVED*** Unsolicited Notification
        }
      },
      :context_specific => {
        :primitive => {
          0 => :string,             ***REMOVED*** password
          1 => :string,             ***REMOVED*** Kerberos v4
          2 => :string,             ***REMOVED*** Kerberos v5
        },
        :constructed => {
          0 => :array,              ***REMOVED*** RFC-2251 Control
          3 => :array,              ***REMOVED*** Seach referral
        }
      }
    }

    DefaultHost = "127.0.0.1"
    DefaultPort = 389
    DefaultAuth = {:method => :anonymous}
    DefaultTreebase = "dc=com"


    ResultStrings = {
      0 => "Success",
      1 => "Operations Error",
      2 => "Protocol Error",
      3 => "Time Limit Exceeded",
      4 => "Size Limit Exceeded",
      12 => "Unavailable crtical extension",
      16 => "No Such Attribute",
      17 => "Undefined Attribute Type",
      20 => "Attribute or Value Exists",
      32 => "No Such Object",
      34 => "Invalid DN Syntax",
      48 => "Invalid DN Syntax",
      48 => "Inappropriate Authentication",
      49 => "Invalid Credentials",
      50 => "Insufficient Access Rights",
      51 => "Busy",
      52 => "Unavailable",
      53 => "Unwilling to perform",
      65 => "Object Class Violation",
      68 => "Entry Already Exists"
    }


    module LdapControls
      PagedResults = "1.2.840.113556.1.4.319" ***REMOVED*** Microsoft evil from RFC 2696
    end


    ***REMOVED***
    ***REMOVED*** LDAP::result2string
    ***REMOVED***
    def LDAP::result2string code ***REMOVED*** :nodoc:
      ResultStrings[code] || "unknown result (***REMOVED***{code})"
    end 


    attr_accessor :host, :port, :base


    ***REMOVED*** Instantiate an object of type Net::LDAP to perform directory operations.
    ***REMOVED*** This constructor takes a Hash containing arguments, all of which are either optional or may be specified later with other methods as described below. The following arguments
    ***REMOVED*** are supported:
    ***REMOVED*** * :host => the LDAP server's IP-address (default 127.0.0.1)
    ***REMOVED*** * :port => the LDAP server's TCP port (default 389)
    ***REMOVED*** * :auth => a Hash containing authorization parameters. Currently supported values include:
    ***REMOVED***   {:method => :anonymous} and
    ***REMOVED***   {:method => :simple, :username => your_user_name, :password => your_password }
    ***REMOVED***   The password parameter may be a Proc that returns a String.
    ***REMOVED*** * :base => a default treebase parameter for searches performed against the LDAP server. If you don't give this value, then each call to ***REMOVED***search must specify a treebase parameter. If you do give this value, then it will be used in subsequent calls to ***REMOVED***search that do not specify a treebase. If you give a treebase value in any particular call to ***REMOVED***search, that value will override any treebase value you give here.
    ***REMOVED*** * :encryption => specifies the encryption to be used in communicating with the LDAP server. The value is either a Hash containing additional parameters, or the Symbol :simple_tls, which is equivalent to specifying the Hash {:method => :simple_tls}. There is a fairly large range of potential values that may be given for this parameter. See ***REMOVED***encryption for details.
    ***REMOVED***
    ***REMOVED*** Instantiating a Net::LDAP object does <i>not</i> result in network traffic to
    ***REMOVED*** the LDAP server. It simply stores the connection and binding parameters in the
    ***REMOVED*** object.
    ***REMOVED***
    def initialize args = {}
      @host = args[:host] || DefaultHost
      @port = args[:port] || DefaultPort
      @verbose = false ***REMOVED*** Make this configurable with a switch on the class.
      @auth = args[:auth] || DefaultAuth
      @base = args[:base] || DefaultTreebase
      encryption args[:encryption] ***REMOVED*** may be nil

      if pr = @auth[:password] and pr.respond_to?(:call)
        @auth[:password] = pr.call
      end

      ***REMOVED*** This variable is only set when we are created with LDAP::open.
      ***REMOVED*** All of our internal methods will connect using it, or else
      ***REMOVED*** they will create their own.
      @open_connection = nil
    end

    ***REMOVED*** Convenience method to specify authentication credentials to the LDAP
    ***REMOVED*** server. Currently supports simple authentication requiring
    ***REMOVED*** a username and password.
    ***REMOVED***
    ***REMOVED*** Observe that on most LDAP servers,
    ***REMOVED*** the username is a complete DN. However, with A/D, it's often possible
    ***REMOVED*** to give only a user-name rather than a complete DN. In the latter
    ***REMOVED*** case, beware that many A/D servers are configured to permit anonymous
    ***REMOVED*** (uncredentialled) binding, and will silently accept your binding
    ***REMOVED*** as anonymous if you give an unrecognized username. This is not usually
    ***REMOVED*** what you want. (See ***REMOVED***get_operation_result.)
    ***REMOVED***
    ***REMOVED*** <b>Important:</b> The password argument may be a Proc that returns a string.
    ***REMOVED*** This makes it possible for you to write client programs that solicit
    ***REMOVED*** passwords from users or from other data sources without showing them
    ***REMOVED*** in your code or on command lines.
    ***REMOVED***
    ***REMOVED***  require 'net/ldap'
    ***REMOVED***  
    ***REMOVED***  ldap = Net::LDAP.new
    ***REMOVED***  ldap.host = server_ip_address
    ***REMOVED***  ldap.authenticate "cn=Your Username,cn=Users,dc=example,dc=com", "your_psw"
    ***REMOVED***
    ***REMOVED*** Alternatively (with a password block):
    ***REMOVED***
    ***REMOVED***  require 'net/ldap'
    ***REMOVED***  
    ***REMOVED***  ldap = Net::LDAP.new
    ***REMOVED***  ldap.host = server_ip_address
    ***REMOVED***  psw = proc { your_psw_function }
    ***REMOVED***  ldap.authenticate "cn=Your Username,cn=Users,dc=example,dc=com", psw
    ***REMOVED***
    def authenticate username, password
      password = password.call if password.respond_to?(:call)
      @auth = {:method => :simple, :username => username, :password => password}
    end

    alias_method :auth, :authenticate

    ***REMOVED*** Convenience method to specify encryption characteristics for connections
    ***REMOVED*** to LDAP servers. Called implicitly by ***REMOVED***new and ***REMOVED***open, but may also be called
    ***REMOVED*** by user code if desired.
    ***REMOVED*** The single argument is generally a Hash (but see below for convenience alternatives).
    ***REMOVED*** This implementation is currently a stub, supporting only a few encryption
    ***REMOVED*** alternatives. As additional capabilities are added, more configuration values
    ***REMOVED*** will be added here.
    ***REMOVED***
    ***REMOVED*** Currently, the only supported argument is {:method => :simple_tls}.
    ***REMOVED*** (Equivalently, you may pass the symbol :simple_tls all by itself, without
    ***REMOVED*** enclosing it in a Hash.)
    ***REMOVED***
    ***REMOVED*** The :simple_tls encryption method encrypts <i>all</i> communications with the LDAP
    ***REMOVED*** server.
    ***REMOVED*** It completely establishes SSL/TLS encryption with the LDAP server 
    ***REMOVED*** before any LDAP-protocol data is exchanged.
    ***REMOVED*** There is no plaintext negotiation and no special encryption-request controls
    ***REMOVED*** are sent to the server. 
    ***REMOVED*** <i>The :simple_tls option is the simplest, easiest way to encrypt communications
    ***REMOVED*** between Net::LDAP and LDAP servers.</i>
    ***REMOVED*** It's intended for cases where you have an implicit level of trust in the authenticity
    ***REMOVED*** of the LDAP server. No validation of the LDAP server's SSL certificate is
    ***REMOVED*** performed. This means that :simple_tls will not produce errors if the LDAP
    ***REMOVED*** server's encryption certificate is not signed by a well-known Certification
    ***REMOVED*** Authority.
    ***REMOVED*** If you get communications or protocol errors when using this option, check
    ***REMOVED*** with your LDAP server administrator. Pay particular attention to the TCP port
    ***REMOVED*** you are connecting to. It's impossible for an LDAP server to support plaintext
    ***REMOVED*** LDAP communications and <i>simple TLS</i> connections on the same port.
    ***REMOVED*** The standard TCP port for unencrypted LDAP connections is 389, but the standard
    ***REMOVED*** port for simple-TLS encrypted connections is 636. Be sure you are using the
    ***REMOVED*** correct port.
    ***REMOVED***
    ***REMOVED*** <i>[Note: a future version of Net::LDAP will support the STARTTLS LDAP control,
    ***REMOVED*** which will enable encrypted communications on the same TCP port used for
    ***REMOVED*** unencrypted connections.]</i>
    ***REMOVED***
    def encryption args
      if args == :simple_tls
        args = {:method => :simple_tls}
      end
      @encryption = args
    end


    ***REMOVED*** ***REMOVED***open takes the same parameters as ***REMOVED***new. ***REMOVED***open makes a network connection to the
    ***REMOVED*** LDAP server and then passes a newly-created Net::LDAP object to the caller-supplied block.
    ***REMOVED*** Within the block, you can call any of the instance methods of Net::LDAP to
    ***REMOVED*** perform operations against the LDAP directory. ***REMOVED***open will perform all the
    ***REMOVED*** operations in the user-supplied block on the same network connection, which
    ***REMOVED*** will be closed automatically when the block finishes.
    ***REMOVED***
    ***REMOVED***  ***REMOVED*** (PSEUDOCODE)
    ***REMOVED***  auth = {:method => :simple, :username => username, :password => password}
    ***REMOVED***  Net::LDAP.open( :host => ipaddress, :port => 389, :auth => auth ) do |ldap|
    ***REMOVED***    ldap.search( ... )
    ***REMOVED***    ldap.add( ... )
    ***REMOVED***    ldap.modify( ... )
    ***REMOVED***  end
    ***REMOVED***
    def LDAP::open args
      ldap1 = LDAP.new args
      ldap1.open {|ldap| yield ldap }
    end

    ***REMOVED*** Returns a meaningful result any time after
    ***REMOVED*** a protocol operation (***REMOVED***bind, ***REMOVED***search, ***REMOVED***add, ***REMOVED***modify, ***REMOVED***rename, ***REMOVED***delete)
    ***REMOVED*** has completed.
    ***REMOVED*** It returns an ***REMOVED***OpenStruct containing an LDAP result code (0 means success),
    ***REMOVED*** and a human-readable string.
    ***REMOVED***  unless ldap.bind
    ***REMOVED***    puts "Result: ***REMOVED***{ldap.get_operation_result.code}"
    ***REMOVED***    puts "Message: ***REMOVED***{ldap.get_operation_result.message}"
    ***REMOVED***  end
    ***REMOVED***
    def get_operation_result
      os = OpenStruct.new
      if @result
        os.code = @result
      else
        os.code = 0
      end
      os.message = LDAP.result2string( os.code )
      os
    end


    ***REMOVED*** Opens a network connection to the server and then
    ***REMOVED*** passes <tt>self</tt> to the caller-supplied block. The connection is
    ***REMOVED*** closed when the block completes. Used for executing multiple
    ***REMOVED*** LDAP operations without requiring a separate network connection
    ***REMOVED*** (and authentication) for each one.
    ***REMOVED*** <i>Note:</i> You do not need to log-in or "bind" to the server. This will
    ***REMOVED*** be done for you automatically.
    ***REMOVED*** For an even simpler approach, see the class method Net::LDAP***REMOVED***open.
    ***REMOVED***
    ***REMOVED***  ***REMOVED*** (PSEUDOCODE)
    ***REMOVED***  auth = {:method => :simple, :username => username, :password => password}
    ***REMOVED***  ldap = Net::LDAP.new( :host => ipaddress, :port => 389, :auth => auth )
    ***REMOVED***  ldap.open do |ldap|
    ***REMOVED***    ldap.search( ... )
    ***REMOVED***    ldap.add( ... )
    ***REMOVED***    ldap.modify( ... )
    ***REMOVED***  end
    ***REMOVED***--
    ***REMOVED*** First we make a connection and then a binding, but we don't
    ***REMOVED*** do anything with the bind results.
    ***REMOVED*** We then pass self to the caller's block, where he will execute
    ***REMOVED*** his LDAP operations. Of course they will all generate auth failures
    ***REMOVED*** if the bind was unsuccessful.
    def open
      raise LdapError.new( "open already in progress" ) if @open_connection
      @open_connection = Connection.new( :host => @host, :port => @port, :encryption => @encryption )
      @open_connection.bind @auth
      yield self
      @open_connection.close
      @open_connection = nil
    end


    ***REMOVED*** Searches the LDAP directory for directory entries.
    ***REMOVED*** Takes a hash argument with parameters. Supported parameters include:
    ***REMOVED*** * :base (a string specifying the tree-base for the search);
    ***REMOVED*** * :filter (an object of type Net::LDAP::Filter, defaults to objectclass=*);
    ***REMOVED*** * :attributes (a string or array of strings specifying the LDAP attributes to return from the server);
    ***REMOVED*** * :return_result (a boolean specifying whether to return a result set).
    ***REMOVED*** * :attributes_only (a boolean flag, defaults false)
    ***REMOVED*** * :scope (one of: Net::LDAP::SearchScope_BaseObject, Net::LDAP::SearchScope_SingleLevel, Net::LDAP::SearchScope_WholeSubtree. Default is WholeSubtree.)
    ***REMOVED***
    ***REMOVED*** ***REMOVED***search queries the LDAP server and passes <i>each entry</i> to the
    ***REMOVED*** caller-supplied block, as an object of type Net::LDAP::Entry.
    ***REMOVED*** If the search returns 1000 entries, the block will
    ***REMOVED*** be called 1000 times. If the search returns no entries, the block will
    ***REMOVED*** not be called.
    ***REMOVED***
    ***REMOVED***--
    ***REMOVED*** ORIGINAL TEXT, replaced 04May06.
    ***REMOVED*** ***REMOVED***search returns either a result-set or a boolean, depending on the
    ***REMOVED*** value of the <tt>:return_result</tt> argument. The default behavior is to return
    ***REMOVED*** a result set, which is a hash. Each key in the hash is a string specifying
    ***REMOVED*** the DN of an entry. The corresponding value for each key is a Net::LDAP::Entry object.
    ***REMOVED*** If you request a result set and ***REMOVED***search fails with an error, it will return nil.
    ***REMOVED*** Call ***REMOVED***get_operation_result to get the error information returned by
    ***REMOVED*** the LDAP server.
    ***REMOVED***++
    ***REMOVED*** ***REMOVED***search returns either a result-set or a boolean, depending on the
    ***REMOVED*** value of the <tt>:return_result</tt> argument. The default behavior is to return
    ***REMOVED*** a result set, which is an Array of objects of class Net::LDAP::Entry.
    ***REMOVED*** If you request a result set and ***REMOVED***search fails with an error, it will return nil.
    ***REMOVED*** Call ***REMOVED***get_operation_result to get the error information returned by
    ***REMOVED*** the LDAP server.
    ***REMOVED***
    ***REMOVED*** When <tt>:return_result => false,</tt> ***REMOVED***search will
    ***REMOVED*** return only a Boolean, to indicate whether the operation succeeded. This can improve performance
    ***REMOVED*** with very large result sets, because the library can discard each entry from memory after
    ***REMOVED*** your block processes it.
    ***REMOVED***
    ***REMOVED***
    ***REMOVED***  treebase = "dc=example,dc=com"
    ***REMOVED***  filter = Net::LDAP::Filter.eq( "mail", "a*.com" )
    ***REMOVED***  attrs = ["mail", "cn", "sn", "objectclass"]
    ***REMOVED***  ldap.search( :base => treebase, :filter => filter, :attributes => attrs, :return_result => false ) do |entry|
    ***REMOVED***    puts "DN: ***REMOVED***{entry.dn}"
    ***REMOVED***    entry.each do |attr, values|
    ***REMOVED***      puts ".......***REMOVED***{attr}:"
    ***REMOVED***      values.each do |value|
    ***REMOVED***        puts "          ***REMOVED***{value}"
    ***REMOVED***      end
    ***REMOVED***    end
    ***REMOVED***  end
    ***REMOVED***
    ***REMOVED***--
    ***REMOVED*** This is a re-implementation of search that replaces the
    ***REMOVED*** original one (now renamed searchx and possibly destined to go away).
    ***REMOVED*** The difference is that we return a dataset (or nil) from the
    ***REMOVED*** call, and pass _each entry_ as it is received from the server
    ***REMOVED*** to the caller-supplied block. This will probably make things
    ***REMOVED*** far faster as we can do useful work during the network latency
    ***REMOVED*** of the search. The downside is that we have no access to the
    ***REMOVED*** whole set while processing the blocks, so we can't do stuff
    ***REMOVED*** like sort the DNs until after the call completes.
    ***REMOVED*** It's also possible that this interacts badly with server timeouts.
    ***REMOVED*** We'll have to ensure that something reasonable happens if
    ***REMOVED*** the caller has processed half a result set when we throw a timeout
    ***REMOVED*** error.
    ***REMOVED*** Another important difference is that we return a result set from
    ***REMOVED*** this method rather than a T/F indication.
    ***REMOVED*** Since this can be very heavy-weight, we define an argument flag
    ***REMOVED*** that the caller can set to suppress the return of a result set,
    ***REMOVED*** if he's planning to process every entry as it comes from the server.
    ***REMOVED***
    ***REMOVED*** REINTERPRETED the result set, 04May06. Originally this was a hash
    ***REMOVED*** of entries keyed by DNs. But let's get away from making users
    ***REMOVED*** handle DNs. Change it to a plain array. Eventually we may
    ***REMOVED*** want to return a Dataset object that delegates to an internal
    ***REMOVED*** array, so we can provide sort methods and what-not.
    ***REMOVED***
    def search args = {}
      args[:base] ||= @base
      result_set = (args and args[:return_result] == false) ? nil : []

      if @open_connection
        @result = @open_connection.search( args ) {|entry|
          result_set << entry if result_set
          yield( entry ) if block_given?
        }
      else
        @result = 0
        conn = Connection.new( :host => @host, :port => @port, :encryption => @encryption )
        if (@result = conn.bind( args[:auth] || @auth )) == 0
          @result = conn.search( args ) {|entry|
            result_set << entry if result_set
            yield( entry ) if block_given?
          }
        end
        conn.close
      end

      @result == 0 and result_set
    end

    ***REMOVED*** ***REMOVED***bind connects to an LDAP server and requests authentication
    ***REMOVED*** based on the <tt>:auth</tt> parameter passed to ***REMOVED***open or ***REMOVED***new.
    ***REMOVED*** It takes no parameters.
    ***REMOVED***
    ***REMOVED*** User code does not need to call ***REMOVED***bind directly. It will be called
    ***REMOVED*** implicitly by the library whenever you invoke an LDAP operation,
    ***REMOVED*** such as ***REMOVED***search or ***REMOVED***add.
    ***REMOVED***
    ***REMOVED*** It is useful, however, to call ***REMOVED***bind in your own code when the
    ***REMOVED*** only operation you intend to perform against the directory is
    ***REMOVED*** to validate a login credential. ***REMOVED***bind returns true or false
    ***REMOVED*** to indicate whether the binding was successful. Reasons for
    ***REMOVED*** failure include malformed or unrecognized usernames and
    ***REMOVED*** incorrect passwords. Use ***REMOVED***get_operation_result to find out
    ***REMOVED*** what happened in case of failure.
    ***REMOVED***
    ***REMOVED*** Here's a typical example using ***REMOVED***bind to authenticate a
    ***REMOVED*** credential which was (perhaps) solicited from the user of a
    ***REMOVED*** web site:
    ***REMOVED***
    ***REMOVED***  require 'net/ldap'
    ***REMOVED***  ldap = Net::LDAP.new
    ***REMOVED***  ldap.host = your_server_ip_address
    ***REMOVED***  ldap.port = 389
    ***REMOVED***  ldap.auth your_user_name, your_user_password
    ***REMOVED***  if ldap.bind
    ***REMOVED***    ***REMOVED*** authentication succeeded
    ***REMOVED***  else
    ***REMOVED***    ***REMOVED*** authentication failed
    ***REMOVED***    p ldap.get_operation_result
    ***REMOVED***  end
    ***REMOVED***
    ***REMOVED*** You don't have to create a new instance of Net::LDAP every time
    ***REMOVED*** you perform a binding in this way. If you prefer, you can cache the Net::LDAP object
    ***REMOVED*** and re-use it to perform subsequent bindings, <i>provided</i> you call
    ***REMOVED*** ***REMOVED***auth to specify a new credential before calling ***REMOVED***bind. Otherwise, you'll
    ***REMOVED*** just re-authenticate the previous user! (You don't need to re-set
    ***REMOVED*** the values of ***REMOVED***host and ***REMOVED***port.) As noted in the documentation for ***REMOVED***auth,
    ***REMOVED*** the password parameter can be a Ruby Proc instead of a String.
    ***REMOVED***
    ***REMOVED***--
    ***REMOVED*** If there is an @open_connection, then perform the bind
    ***REMOVED*** on it. Otherwise, connect, bind, and disconnect.
    ***REMOVED*** The latter operation is obviously useful only as an auth check.
    ***REMOVED***
    def bind auth=@auth
      if @open_connection
        @result = @open_connection.bind auth
      else
        conn = Connection.new( :host => @host, :port => @port , :encryption => @encryption)
        @result = conn.bind @auth
        conn.close
      end

      @result == 0
    end

    ***REMOVED***
    ***REMOVED*** ***REMOVED***bind_as is for testing authentication credentials.
    ***REMOVED***
    ***REMOVED*** As described under ***REMOVED***bind, most LDAP servers require that you supply a complete DN
    ***REMOVED*** as a binding-credential, along with an authenticator such as a password.
    ***REMOVED*** But for many applications (such as authenticating users to a Rails application),
    ***REMOVED*** you often don't have a full DN to identify the user. You usually get a simple
    ***REMOVED*** identifier like a username or an email address, along with a password.
    ***REMOVED*** ***REMOVED***bind_as allows you to authenticate these user-identifiers.
    ***REMOVED***
    ***REMOVED*** ***REMOVED***bind_as is a combination of a search and an LDAP binding. First, it connects and
    ***REMOVED*** binds to the directory as normal. Then it searches the directory for an entry
    ***REMOVED*** corresponding to the email address, username, or other string that you supply.
    ***REMOVED*** If the entry exists, then ***REMOVED***bind_as will <b>re-bind</b> as that user with the
    ***REMOVED*** password (or other authenticator) that you supply.
    ***REMOVED***
    ***REMOVED*** ***REMOVED***bind_as takes the same parameters as ***REMOVED***search, <i>with the addition of an
    ***REMOVED*** authenticator.</i> Currently, this authenticator must be <tt>:password</tt>.
    ***REMOVED*** Its value may be either a String, or a +proc+ that returns a String.
    ***REMOVED*** ***REMOVED***bind_as returns +false+ on failure. On success, it returns a result set,
    ***REMOVED*** just as ***REMOVED***search does. This result set is an Array of objects of
    ***REMOVED*** type Net::LDAP::Entry. It contains the directory attributes corresponding to
    ***REMOVED*** the user. (Just test whether the return value is logically true, if you don't
    ***REMOVED*** need this additional information.)
    ***REMOVED***
    ***REMOVED*** Here's how you would use ***REMOVED***bind_as to authenticate an email address and password:
    ***REMOVED***
    ***REMOVED***  require 'net/ldap'
    ***REMOVED***  
    ***REMOVED***  user,psw = "joe_user@yourcompany.com", "joes_psw"
    ***REMOVED***  
    ***REMOVED***  ldap = Net::LDAP.new
    ***REMOVED***  ldap.host = "192.168.0.100"
    ***REMOVED***  ldap.port = 389
    ***REMOVED***  ldap.auth "cn=manager,dc=yourcompany,dc=com", "topsecret"
    ***REMOVED***  
    ***REMOVED***  result = ldap.bind_as(
    ***REMOVED***    :base => "dc=yourcompany,dc=com",
    ***REMOVED***    :filter => "(mail=***REMOVED***{user})",
    ***REMOVED***    :password => psw
    ***REMOVED***  )
    ***REMOVED***  if result
    ***REMOVED***    puts "Authenticated ***REMOVED***{result.first.dn}"
    ***REMOVED***  else
    ***REMOVED***    puts "Authentication FAILED."
    ***REMOVED***  end
    def bind_as args={}
      result = false
      open {|me|
        rs = search args
        if rs and rs.first and dn = rs.first.dn
          password = args[:password]
          password = password.call if password.respond_to?(:call)
          result = rs if bind :method => :simple, :username => dn, :password => password
        end
      }
      result
    end


    ***REMOVED*** Adds a new entry to the remote LDAP server.
    ***REMOVED*** Supported arguments:
    ***REMOVED*** :dn :: Full DN of the new entry
    ***REMOVED*** :attributes :: Attributes of the new entry.
    ***REMOVED***
    ***REMOVED*** The attributes argument is supplied as a Hash keyed by Strings or Symbols
    ***REMOVED*** giving the attribute name, and mapping to Strings or Arrays of Strings
    ***REMOVED*** giving the actual attribute values. Observe that most LDAP directories
    ***REMOVED*** enforce schema constraints on the attributes contained in entries.
    ***REMOVED*** ***REMOVED***add will fail with a server-generated error if your attributes violate
    ***REMOVED*** the server-specific constraints.
    ***REMOVED*** Here's an example:
    ***REMOVED***
    ***REMOVED***  dn = "cn=George Smith,ou=people,dc=example,dc=com"
    ***REMOVED***  attr = {
    ***REMOVED***    :cn => "George Smith",
    ***REMOVED***    :objectclass => ["top", "inetorgperson"],
    ***REMOVED***    :sn => "Smith",
    ***REMOVED***    :mail => "gsmith@example.com"
    ***REMOVED***  }
    ***REMOVED***  Net::LDAP.open (:host => host) do |ldap|
    ***REMOVED***    ldap.add( :dn => dn, :attributes => attr )
    ***REMOVED***  end
    ***REMOVED***
    def add args
      if @open_connection
          @result = @open_connection.add( args )
      else
        @result = 0
        conn = Connection.new( :host => @host, :port => @port, :encryption => @encryption)
        if (@result = conn.bind( args[:auth] || @auth )) == 0
          @result = conn.add( args )
        end
        conn.close
      end
      @result == 0
    end


    ***REMOVED*** Modifies the attribute values of a particular entry on the LDAP directory.
    ***REMOVED*** Takes a hash with arguments. Supported arguments are:
    ***REMOVED*** :dn :: (the full DN of the entry whose attributes are to be modified)
    ***REMOVED*** :operations :: (the modifications to be performed, detailed next)
    ***REMOVED***
    ***REMOVED*** This method returns True or False to indicate whether the operation
    ***REMOVED*** succeeded or failed, with extended information available by calling
    ***REMOVED*** ***REMOVED***get_operation_result.
    ***REMOVED***
    ***REMOVED*** Also see ***REMOVED***add_attribute, ***REMOVED***replace_attribute, or ***REMOVED***delete_attribute, which
    ***REMOVED*** provide simpler interfaces to this functionality.
    ***REMOVED***
    ***REMOVED*** The LDAP protocol provides a full and well thought-out set of operations
    ***REMOVED*** for changing the values of attributes, but they are necessarily somewhat complex
    ***REMOVED*** and not always intuitive. If these instructions are confusing or incomplete,
    ***REMOVED*** please send us email or create a bug report on rubyforge.
    ***REMOVED***
    ***REMOVED*** The :operations parameter to ***REMOVED***modify takes an array of operation-descriptors.
    ***REMOVED*** Each individual operation is specified in one element of the array, and
    ***REMOVED*** most LDAP servers will attempt to perform the operations in order.
    ***REMOVED***
    ***REMOVED*** Each of the operations appearing in the Array must itself be an Array
    ***REMOVED*** with exactly three elements:
    ***REMOVED*** an operator:: must be :add, :replace, or :delete
    ***REMOVED*** an attribute name:: the attribute name (string or symbol) to modify
    ***REMOVED*** a value:: either a string or an array of strings.
    ***REMOVED***
    ***REMOVED*** The :add operator will, unsurprisingly, add the specified values to
    ***REMOVED*** the specified attribute. If the attribute does not already exist,
    ***REMOVED*** :add will create it. Most LDAP servers will generate an error if you
    ***REMOVED*** try to add a value that already exists.
    ***REMOVED***
    ***REMOVED*** :replace will erase the current value(s) for the specified attribute,
    ***REMOVED*** if there are any, and replace them with the specified value(s).
    ***REMOVED***
    ***REMOVED*** :delete will remove the specified value(s) from the specified attribute.
    ***REMOVED*** If you pass nil, an empty string, or an empty array as the value parameter
    ***REMOVED*** to a :delete operation, the _entire_ _attribute_ will be deleted, along
    ***REMOVED*** with all of its values.
    ***REMOVED***
    ***REMOVED*** For example:
    ***REMOVED***
    ***REMOVED***  dn = "mail=modifyme@example.com,ou=people,dc=example,dc=com"
    ***REMOVED***  ops = [
    ***REMOVED***    [:add, :mail, "aliasaddress@example.com"],
    ***REMOVED***    [:replace, :mail, ["newaddress@example.com", "newalias@example.com"]],
    ***REMOVED***    [:delete, :sn, nil]
    ***REMOVED***  ]
    ***REMOVED***  ldap.modify :dn => dn, :operations => ops
    ***REMOVED***
    ***REMOVED*** <i>(This example is contrived since you probably wouldn't add a mail
    ***REMOVED*** value right before replacing the whole attribute, but it shows that order
    ***REMOVED*** of execution matters. Also, many LDAP servers won't let you delete SN
    ***REMOVED*** because that would be a schema violation.)</i>
    ***REMOVED***
    ***REMOVED*** It's essential to keep in mind that if you specify more than one operation in
    ***REMOVED*** a call to ***REMOVED***modify, most LDAP servers will attempt to perform all of the operations
    ***REMOVED*** in the order you gave them.
    ***REMOVED*** This matters because you may specify operations on the
    ***REMOVED*** same attribute which must be performed in a certain order.
    ***REMOVED***
    ***REMOVED*** Most LDAP servers will _stop_ processing your modifications if one of them
    ***REMOVED*** causes an error on the server (such as a schema-constraint violation).
    ***REMOVED*** If this happens, you will probably get a result code from the server that
    ***REMOVED*** reflects only the operation that failed, and you may or may not get extended
    ***REMOVED*** information that will tell you which one failed. ***REMOVED***modify has no notion
    ***REMOVED*** of an atomic transaction. If you specify a chain of modifications in one
    ***REMOVED*** call to ***REMOVED***modify, and one of them fails, the preceding ones will usually
    ***REMOVED*** not be "rolled back," resulting in a partial update. This is a limitation
    ***REMOVED*** of the LDAP protocol, not of Net::LDAP.
    ***REMOVED***
    ***REMOVED*** The lack of transactional atomicity in LDAP means that you're usually
    ***REMOVED*** better off using the convenience methods ***REMOVED***add_attribute, ***REMOVED***replace_attribute,
    ***REMOVED*** and ***REMOVED***delete_attribute, which are are wrappers over ***REMOVED***modify. However, certain
    ***REMOVED*** LDAP servers may provide concurrency semantics, in which the several operations
    ***REMOVED*** contained in a single ***REMOVED***modify call are not interleaved with other
    ***REMOVED*** modification-requests received simultaneously by the server.
    ***REMOVED*** It bears repeating that this concurrency does _not_ imply transactional
    ***REMOVED*** atomicity, which LDAP does not provide.
    ***REMOVED***
    def modify args
      if @open_connection
          @result = @open_connection.modify( args )
      else
        @result = 0
        conn = Connection.new( :host => @host, :port => @port, :encryption => @encryption )
        if (@result = conn.bind( args[:auth] || @auth )) == 0
          @result = conn.modify( args )
        end
        conn.close
      end
      @result == 0
    end


    ***REMOVED*** Add a value to an attribute.
    ***REMOVED*** Takes the full DN of the entry to modify,
    ***REMOVED*** the name (Symbol or String) of the attribute, and the value (String or
    ***REMOVED*** Array). If the attribute does not exist (and there are no schema violations),
    ***REMOVED*** ***REMOVED***add_attribute will create it with the caller-specified values.
    ***REMOVED*** If the attribute already exists (and there are no schema violations), the
    ***REMOVED*** caller-specified values will be _added_ to the values already present.
    ***REMOVED***
    ***REMOVED*** Returns True or False to indicate whether the operation
    ***REMOVED*** succeeded or failed, with extended information available by calling
    ***REMOVED*** ***REMOVED***get_operation_result. See also ***REMOVED***replace_attribute and ***REMOVED***delete_attribute.
    ***REMOVED***
    ***REMOVED***  dn = "cn=modifyme,dc=example,dc=com"
    ***REMOVED***  ldap.add_attribute dn, :mail, "newmailaddress@example.com"
    ***REMOVED***
    def add_attribute dn, attribute, value
      modify :dn => dn, :operations => [[:add, attribute, value]]
    end

    ***REMOVED*** Replace the value of an attribute.
    ***REMOVED*** ***REMOVED***replace_attribute can be thought of as equivalent to calling ***REMOVED***delete_attribute
    ***REMOVED*** followed by ***REMOVED***add_attribute. It takes the full DN of the entry to modify,
    ***REMOVED*** the name (Symbol or String) of the attribute, and the value (String or
    ***REMOVED*** Array). If the attribute does not exist, it will be created with the
    ***REMOVED*** caller-specified value(s). If the attribute does exist, its values will be
    ***REMOVED*** _discarded_ and replaced with the caller-specified values.
    ***REMOVED***
    ***REMOVED*** Returns True or False to indicate whether the operation
    ***REMOVED*** succeeded or failed, with extended information available by calling
    ***REMOVED*** ***REMOVED***get_operation_result. See also ***REMOVED***add_attribute and ***REMOVED***delete_attribute.
    ***REMOVED***
    ***REMOVED***  dn = "cn=modifyme,dc=example,dc=com"
    ***REMOVED***  ldap.replace_attribute dn, :mail, "newmailaddress@example.com"
    ***REMOVED***
    def replace_attribute dn, attribute, value
      modify :dn => dn, :operations => [[:replace, attribute, value]]
    end

    ***REMOVED*** Delete an attribute and all its values.
    ***REMOVED*** Takes the full DN of the entry to modify, and the
    ***REMOVED*** name (Symbol or String) of the attribute to delete.
    ***REMOVED***
    ***REMOVED*** Returns True or False to indicate whether the operation
    ***REMOVED*** succeeded or failed, with extended information available by calling
    ***REMOVED*** ***REMOVED***get_operation_result. See also ***REMOVED***add_attribute and ***REMOVED***replace_attribute.
    ***REMOVED***
    ***REMOVED***  dn = "cn=modifyme,dc=example,dc=com"
    ***REMOVED***  ldap.delete_attribute dn, :mail
    ***REMOVED***
    def delete_attribute dn, attribute
      modify :dn => dn, :operations => [[:delete, attribute, nil]]
    end


    ***REMOVED*** Rename an entry on the remote DIS by changing the last RDN of its DN.
    ***REMOVED*** _Documentation_ _stub_
    ***REMOVED***
    def rename args
      if @open_connection
          @result = @open_connection.rename( args )
      else
        @result = 0
        conn = Connection.new( :host => @host, :port => @port, :encryption => @encryption )
        if (@result = conn.bind( args[:auth] || @auth )) == 0
          @result = conn.rename( args )
        end
        conn.close
      end
      @result == 0
    end

    ***REMOVED*** modify_rdn is an alias for ***REMOVED***rename.
    def modify_rdn args
      rename args
    end

    ***REMOVED*** Delete an entry from the LDAP directory.
    ***REMOVED*** Takes a hash of arguments.
    ***REMOVED*** The only supported argument is :dn, which must
    ***REMOVED*** give the complete DN of the entry to be deleted.
    ***REMOVED*** Returns True or False to indicate whether the delete
    ***REMOVED*** succeeded. Extended status information is available by
    ***REMOVED*** calling ***REMOVED***get_operation_result.
    ***REMOVED***
    ***REMOVED***  dn = "mail=deleteme@example.com,ou=people,dc=example,dc=com"
    ***REMOVED***  ldap.delete :dn => dn
    ***REMOVED***
    def delete args
      if @open_connection
          @result = @open_connection.delete( args )
      else
        @result = 0
        conn = Connection.new( :host => @host, :port => @port, :encryption => @encryption )
        if (@result = conn.bind( args[:auth] || @auth )) == 0
          @result = conn.delete( args )
        end
        conn.close
      end
      @result == 0
    end

  end ***REMOVED*** class LDAP



  class LDAP
  ***REMOVED*** This is a private class used internally by the library. It should not be called by user code.
  class Connection ***REMOVED*** :nodoc:

    LdapVersion = 3


    ***REMOVED***--
    ***REMOVED*** initialize
    ***REMOVED***
    def initialize server
      begin
        @conn = TCPsocket.new( server[:host], server[:port] )
      rescue
        raise LdapError.new( "no connection to server" )
      end

      if server[:encryption]
        setup_encryption server[:encryption]
      end

      yield self if block_given?
    end


    ***REMOVED***--
    ***REMOVED*** Helper method called only from new, and only after we have a successfully-opened
    ***REMOVED*** @conn instance variable, which is a TCP connection.
    ***REMOVED*** Depending on the received arguments, we establish SSL, potentially replacing
    ***REMOVED*** the value of @conn accordingly.
    ***REMOVED*** Don't generate any errors here if no encryption is requested.
    ***REMOVED*** DO raise LdapError objects if encryption is requested and we have trouble setting
    ***REMOVED*** it up. That includes if OpenSSL is not set up on the machine. (Question:
    ***REMOVED*** how does the Ruby OpenSSL wrapper react in that case?)
    ***REMOVED*** DO NOT filter exceptions raised by the OpenSSL library. Let them pass back
    ***REMOVED*** to the user. That should make it easier for us to debug the problem reports.
    ***REMOVED*** Presumably (hopefully?) that will also produce recognizable errors if someone
    ***REMOVED*** tries to use this on a machine without OpenSSL.
    ***REMOVED***
    ***REMOVED*** The simple_tls method is intended as the simplest, stupidest, easiest solution
    ***REMOVED*** for people who want nothing more than encrypted comms with the LDAP server.
    ***REMOVED*** It doesn't do any server-cert validation and requires nothing in the way
    ***REMOVED*** of key files and root-cert files, etc etc.
    ***REMOVED*** OBSERVE: WE REPLACE the value of @conn, which is presumed to be a connected
    ***REMOVED*** TCPsocket object.
    ***REMOVED***
    def setup_encryption args
      case args[:method]
      when :simple_tls
        raise LdapError.new("openssl unavailable") unless $net_ldap_openssl_available
        ctx = OpenSSL::SSL::SSLContext.new
        @conn = OpenSSL::SSL::SSLSocket.new(@conn, ctx)
        @conn.connect
        @conn.sync_close = true
      ***REMOVED*** additional branches requiring server validation and peer certs, etc. go here.
      else
        raise LdapError.new( "unsupported encryption method ***REMOVED***{args[:method]}" )
      end
    end

    ***REMOVED***--
    ***REMOVED*** close
    ***REMOVED*** This is provided as a convenience method to make
    ***REMOVED*** sure a connection object gets closed without waiting
    ***REMOVED*** for a GC to happen. Clients shouldn't have to call it,
    ***REMOVED*** but perhaps it will come in handy someday.
    def close
      @conn.close
      @conn = nil
    end

    ***REMOVED***--
    ***REMOVED*** next_msgid
    ***REMOVED***
    def next_msgid
      @msgid ||= 0
      @msgid += 1
    end


    ***REMOVED***--
    ***REMOVED*** bind
    ***REMOVED***
    def bind auth
      user,psw = case auth[:method]
      when :anonymous
        ["",""]
      when :simple
        [auth[:username] || auth[:dn], auth[:password]]
      end
      raise LdapError.new( "invalid binding information" ) unless (user && psw)

      msgid = next_msgid.to_ber
      request = [LdapVersion.to_ber, user.to_ber, psw.to_ber_contextspecific(0)].to_ber_appsequence(0)
      request_pkt = [msgid, request].to_ber_sequence
      @conn.write request_pkt

      (be = @conn.read_ber(AsnSyntax) and pdu = Net::LdapPdu.new( be )) or raise LdapError.new( "no bind result" )
      pdu.result_code
    end

    ***REMOVED***--
    ***REMOVED*** search
    ***REMOVED*** Alternate implementation, this yields each search entry to the caller
    ***REMOVED*** as it are received.
    ***REMOVED*** TODO, certain search parameters are hardcoded.
    ***REMOVED*** TODO, if we mis-parse the server results or the results are wrong, we can block
    ***REMOVED*** forever. That's because we keep reading results until we get a type-5 packet,
    ***REMOVED*** which might never come. We need to support the time-limit in the protocol.
    ***REMOVED***--
    ***REMOVED*** WARNING: this code substantially recapitulates the searchx method.
    ***REMOVED***
    ***REMOVED*** 02May06: Well, I added support for RFC-2696-style paged searches.
    ***REMOVED*** This is used on all queries because the extension is marked non-critical.
    ***REMOVED*** As far as I know, only A/D uses this, but it's required for A/D. Otherwise
    ***REMOVED*** you won't get more than 1000 results back from a query.
    ***REMOVED*** This implementation is kindof clunky and should probably be refactored.
    ***REMOVED*** Also, is it my imagination, or are A/Ds the slowest directory servers ever???
    ***REMOVED***
    def search args = {}
      search_filter = (args && args[:filter]) || Filter.eq( "objectclass", "*" )
      search_filter = Filter.construct(search_filter) if search_filter.is_a?(String)
      search_base = (args && args[:base]) || "dc=example,dc=com"
      search_attributes = ((args && args[:attributes]) || []).map {|attr| attr.to_s.to_ber}
      return_referrals = args && args[:return_referrals] == true

      attributes_only = (args and args[:attributes_only] == true)
      scope = args[:scope] || Net::LDAP::SearchScope_WholeSubtree
      raise LdapError.new( "invalid search scope" ) unless SearchScopes.include?(scope)

      ***REMOVED*** An interesting value for the size limit would be close to A/D's built-in
      ***REMOVED*** page limit of 1000 records, but openLDAP newer than version 2.2.0 chokes
      ***REMOVED*** on anything bigger than 126. You get a silent error that is easily visible
      ***REMOVED*** by running slapd in debug mode. Go figure.
      rfc2696_cookie = [126, ""]
      result_code = 0

      loop {
        ***REMOVED*** should collect this into a private helper to clarify the structure

        request = [
          search_base.to_ber,
          scope.to_ber_enumerated,
          0.to_ber_enumerated,
          0.to_ber,
          0.to_ber,
          attributes_only.to_ber,
          search_filter.to_ber,
          search_attributes.to_ber_sequence
        ].to_ber_appsequence(3)
  
        controls = [
          [
          LdapControls::PagedResults.to_ber,
          false.to_ber, ***REMOVED*** criticality MUST be false to interoperate with normal LDAPs.
          rfc2696_cookie.map{|v| v.to_ber}.to_ber_sequence.to_s.to_ber
          ].to_ber_sequence
        ].to_ber_contextspecific(0)

        pkt = [next_msgid.to_ber, request, controls].to_ber_sequence
        @conn.write pkt

        result_code = 0
        controls = []

        while (be = @conn.read_ber(AsnSyntax)) && (pdu = LdapPdu.new( be ))
          case pdu.app_tag
          when 4 ***REMOVED*** search-data
            yield( pdu.search_entry ) if block_given?
          when 19 ***REMOVED*** search-referral
            if return_referrals
              if block_given?
                se = Net::LDAP::Entry.new
                se[:search_referrals] = (pdu.search_referrals || [])
                yield se
              end
            end
            ***REMOVED***p pdu.referrals
          when 5 ***REMOVED*** search-result
            result_code = pdu.result_code
            controls = pdu.result_controls
            break
          else
            raise LdapError.new( "invalid response-type in search: ***REMOVED***{pdu.app_tag}" )
          end
        end

        ***REMOVED*** When we get here, we have seen a type-5 response.
        ***REMOVED*** If there is no error AND there is an RFC-2696 cookie,
        ***REMOVED*** then query again for the next page of results.
        ***REMOVED*** If not, we're done.
        ***REMOVED*** Don't screw this up or we'll break every search we do.
        more_pages = false
        if result_code == 0 and controls
          controls.each do |c|
            if c.oid == LdapControls::PagedResults
              more_pages = false ***REMOVED*** just in case some bogus server sends us >1 of these.
              if c.value and c.value.length > 0
                cookie = c.value.read_ber[1]
                if cookie and cookie.length > 0
                  rfc2696_cookie[1] = cookie
                  more_pages = true
                end
              end
            end
          end
        end

        break unless more_pages
      } ***REMOVED*** loop

      result_code
    end




    ***REMOVED***--
    ***REMOVED*** modify
    ***REMOVED*** TODO, need to support a time limit, in case the server fails to respond.
    ***REMOVED*** TODO!!! We're throwing an exception here on empty DN.
    ***REMOVED*** Should return a proper error instead, probaby from farther up the chain.
    ***REMOVED*** TODO!!! If the user specifies a bogus opcode, we'll throw a
    ***REMOVED*** confusing error here ("to_ber_enumerated is not defined on nil").
    ***REMOVED***
    def modify args
      modify_dn = args[:dn] or raise "Unable to modify empty DN"
      modify_ops = []
      a = args[:operations] and a.each {|op, attr, values|
        ***REMOVED*** TODO, fix the following line, which gives a bogus error
        ***REMOVED*** if the opcode is invalid.
        op_1 = {:add => 0, :delete => 1, :replace => 2} [op.to_sym].to_ber_enumerated
        modify_ops << [op_1, [attr.to_s.to_ber, values.to_a.map {|v| v.to_ber}.to_ber_set].to_ber_sequence].to_ber_sequence
      }

      request = [modify_dn.to_ber, modify_ops.to_ber_sequence].to_ber_appsequence(6)
      pkt = [next_msgid.to_ber, request].to_ber_sequence
      @conn.write pkt

      (be = @conn.read_ber(AsnSyntax)) && (pdu = LdapPdu.new( be )) && (pdu.app_tag == 7) or raise LdapError.new( "response missing or invalid" )
      pdu.result_code
    end


    ***REMOVED***--
    ***REMOVED*** add
    ***REMOVED*** TODO, need to support a time limit, in case the server fails to respond.
    ***REMOVED***
    def add args
      add_dn = args[:dn] or raise LdapError.new("Unable to add empty DN")
      add_attrs = []
      a = args[:attributes] and a.each {|k,v|
        add_attrs << [ k.to_s.to_ber, v.to_a.map {|m| m.to_ber}.to_ber_set ].to_ber_sequence
      }

      request = [add_dn.to_ber, add_attrs.to_ber_sequence].to_ber_appsequence(8)
      pkt = [next_msgid.to_ber, request].to_ber_sequence
      @conn.write pkt

      (be = @conn.read_ber(AsnSyntax)) && (pdu = LdapPdu.new( be )) && (pdu.app_tag == 9) or raise LdapError.new( "response missing or invalid" )
      pdu.result_code
    end


    ***REMOVED***--
    ***REMOVED*** rename
    ***REMOVED*** TODO, need to support a time limit, in case the server fails to respond.
    ***REMOVED***
    def rename args
      old_dn = args[:olddn] or raise "Unable to rename empty DN"
      new_rdn = args[:newrdn] or raise "Unable to rename to empty RDN"
      delete_attrs = args[:delete_attributes] ? true : false

      request = [old_dn.to_ber, new_rdn.to_ber, delete_attrs.to_ber].to_ber_appsequence(12)
      pkt = [next_msgid.to_ber, request].to_ber_sequence
      @conn.write pkt

      (be = @conn.read_ber(AsnSyntax)) && (pdu = LdapPdu.new( be )) && (pdu.app_tag == 13) or raise LdapError.new( "response missing or invalid" )
      pdu.result_code
    end


    ***REMOVED***--
    ***REMOVED*** delete
    ***REMOVED*** TODO, need to support a time limit, in case the server fails to respond.
    ***REMOVED***
    def delete args
      dn = args[:dn] or raise "Unable to delete empty DN"

      request = dn.to_s.to_ber_application_string(10)
      pkt = [next_msgid.to_ber, request].to_ber_sequence
      @conn.write pkt

      (be = @conn.read_ber(AsnSyntax)) && (pdu = LdapPdu.new( be )) && (pdu.app_tag == 11) or raise LdapError.new( "response missing or invalid" )
      pdu.result_code
    end


  end ***REMOVED*** class Connection
  end ***REMOVED*** class LDAP


end ***REMOVED*** module Net


