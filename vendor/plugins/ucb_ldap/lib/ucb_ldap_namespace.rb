
module UCB
  module LDAP
    ***REMOVED******REMOVED***
    ***REMOVED*** Class for accessing the Namespace/Name part of LDAP.
    ***REMOVED***
    class Namespace < Entry
      @tree_base = 'ou=names,ou=namespace,dc=berkeley,dc=edu'
      @entity_name = 'namespaceName'
      
      ***REMOVED******REMOVED***
      ***REMOVED*** Returns name
      ***REMOVED***
      def name
        cn.first
      end

      ***REMOVED******REMOVED***
      ***REMOVED*** Returns +Array+ of services
      ***REMOVED***
      def services
        berkeleyEduServices
      end

      ***REMOVED******REMOVED***
      ***REMOVED*** Returns uid
      ***REMOVED***
      def uid
        super.first
      end
      
      class << self
        ***REMOVED******REMOVED***
        ***REMOVED*** Returns an +Array+ of Namespace for _uid_.
        ***REMOVED***
        def find_by_uid(uid)
          search(:filter => "uid=***REMOVED***{uid}")
        end

        ***REMOVED******REMOVED***
        ***REMOVED*** Returns Namespace instance for _cn_.
        ***REMOVED***
        def find_by_cn(cn)
          search(:filter => "cn=***REMOVED***{cn}").first
        end
      end
    end
    
  end  
end
