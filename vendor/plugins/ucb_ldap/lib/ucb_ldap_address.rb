
module UCB
  module LDAP
    ***REMOVED*** = UCB::LDAP::Address
    ***REMOVED*** 
    ***REMOVED*** This class models a person address instance in the UCB LDAP directory.
    ***REMOVED***
    ***REMOVED***   a = Address.find_by_uid("1234")       ***REMOVED***=> [***REMOVED***<UCB::LDAP::Address: ...>, ...]
    ***REMOVED***
    ***REMOVED*** Addresses are usually loaded through a Person instance:
    ***REMOVED***
    ***REMOVED***   p = Person.find_by_uid("1234")    ***REMOVED***=> ***REMOVED***<UCB::LDAP::Person: ...>
    ***REMOVED***   addrs = p.addresses               ***REMOVED***=> [***REMOVED***<UCB::LDAP::Address: ...>, ...]
    ***REMOVED***
    ***REMOVED*** == Note on Binds
    ***REMOVED*** 
    ***REMOVED*** You must have a privileged bind and pass your credentials to UCB::LDAP.authenticate()
    ***REMOVED*** before performing your Address search.
    ***REMOVED***
    class Address < Entry
      @entity_name = 'personAddress'

      def primary_work_address?
        berkeleyEduPersonAddressPrimaryFlag
      end
      
      def address_type
        berkeleyEduPersonAddressType
      end
      
      def building_code
        berkeleyEduPersonAddressBuildingCode
      end
      
      def city
        l.first
      end
      
      def country_code
        berkeleyEduPersonAddressCountryCode
      end
      
      def department_name
        berkeleyEduPersonAddressUnitCalNetDeptName
      end
      
      def department_acronym
        berkeleyEduPersonAddressUnitHRDeptName
      end
      
      def directories
        berkeleyEduPersonAddressPublications
      end
      
      ***REMOVED*** Returns email address associated with this Address.
      def email
        mail.first
      end
      
      def mail_code
        berkeleyEduPersonAddressMailCode
      end
      
      def mail_release?
        berkeleyEduEmailRelFlag
      end
      
      def phone
        telephoneNumber.first
      end
      
      ***REMOVED*** Returns postal address as an Array.
      ***REMOVED***
      ***REMOVED***   addr.attribute(:postalAddress) ***REMOVED***=> '501 Banway Bldg.$Berkeley, CA 94720-3814$USA'
      ***REMOVED***   addr.postal_address            ***REMOVED***=> ['501 Banway Bldg.', 'Berkeley, CA 94720-3814', 'USA']
      ***REMOVED***
      def postal_address
        postalAddress == [] ? nil : postalAddress.split("$")  
      end
      
      def sort_order
        berkeleyEduPersonAddressSortOrder.first || 0
      end
      
      def state
        st.first
      end
      
      def zip
        postalCode
      end
      
      class << self
        ***REMOVED*** Returns an Array of Address for <tt>uid</tt>, sorted by sort_order().
        ***REMOVED*** Returns an empty Array ([]) if nothing is found.  
        ***REMOVED***
        def find_by_uid(uid)
          base = "uid=***REMOVED***{uid},ou=people,dc=berkeley,dc=edu"
          filter = Net::LDAP::Filter.eq("objectclass", 'berkeleyEduPersonAddress')
          search(:base => base, :filter => filter).sort_by{|addr| addr.sort_order}
        end
         
      end
    end
  end
end