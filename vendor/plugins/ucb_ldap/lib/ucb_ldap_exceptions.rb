module UCB
  module LDAP
 
    class BadAttributeNameException < Exception ***REMOVED***:nodoc:
    end

    class BindFailedException < Exception ***REMOVED***:nodoc:
      def initialize
        super("Failed to bind username '***REMOVED***{UCB::LDAP.username}' to '***REMOVED***{UCB::LDAP.host}'")
      end
    end
   
    class ConnectionFailedException < Exception ***REMOVED***:nodoc:
      def initialize
        super("Failed to connect to ldap host '***REMOVED***{UCB::LDAP.host}''")
      end
    end
   
    class DirectoryNotUpdatedException < Exception ***REMOVED***:nodoc:
      def initialize
        result = UCB::LDAP.net_ldap.get_operation_result 
        super("(Code=***REMOVED***{result.code}) ***REMOVED***{result.message}")
      end
    end
   
 end
end