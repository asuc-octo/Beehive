
module UCB::LDAP
  module GenericAttributes
    
  
    ***REMOVED*** Returns +true+ if the entry represents a test entry.
    def test?
      berkeleyEduTestIDFlag
    end
    
    def uid
      super.first
    end
    
    def firstname
      givenname.first
    end
    alias :first_name :firstname
    
    def lastname
      sn.first
    end
    alias :last_name :lastname
    
    def email
      mail.first
    end
    
    def phone
      telephoneNumber.first
    end

    ***REMOVED*** Returns +Array+ of Affiliation for this Person. Requires a bind with access to affiliations.
    ***REMOVED*** See UCB::LDAP.authenticate().
    def affiliate_affiliations
      @affiliate_affiliations ||= Affiliation.find_by_uid(uid)
    end
 
    ***REMOVED*** Returns +Array+ of Address for this Person.
    ***REMOVED*** Requires a bind with access to addresses.
    ***REMOVED*** See UCB::LDAP.authenticate().
    def addresses
      @addresses ||= Address.find_by_uid(uid)
    end
     
    ***REMOVED*** Returns +Array+ of Namespace for this Person.
    ***REMOVED*** Requires a bind with access to namespaces.
    ***REMOVED*** See UCB::LDAP.authenticate().
    def namespaces
      @namespaces ||= Namespace.find_by_uid(uid)
    end
   
    ***REMOVED*** Returns +Array+ of Service for this Person.
    ***REMOVED*** Requires a bind with access to services.
    ***REMOVED*** See UCB::LDAP.authenticate().
    def services
      @services ||= Service.find_by_uid(uid)
    end
    
    ***REMOVED*** Returns +Array+ of Address for this Person.
    ***REMOVED*** Requires a bind with access to addresses.
    ***REMOVED*** See UCB::LDAP.authenticate().
    def addresses
      @addresses ||= Address.find_by_uid(uid)
    end
  
  end
end
