
module UCB
  module LDAP
    ***REMOVED******REMOVED***
    ***REMOVED*** = UCB::LDAP::Service
    ***REMOVED*** 
    ***REMOVED*** This class models a person's service entries in the UCB LDAP directory.
    ***REMOVED***
    ***REMOVED***   services = Services.find_by_uid("1234")       ***REMOVED***=> [***REMOVED***<UCB::LDAP::Service: ...>, ...]
    ***REMOVED***
    ***REMOVED*** Servicess are usually loaded through a Person instance:
    ***REMOVED***
    ***REMOVED***   p = Person.find_by_uid("1234")    ***REMOVED***=> ***REMOVED***<UCB::LDAP::Person: ...>
    ***REMOVED***   services = p.services        ***REMOVED***=> [***REMOVED***<UCB::LDAP::Service: ...>, ...]
    ***REMOVED***
    ***REMOVED*** == Note on Binds
    ***REMOVED*** 
    ***REMOVED*** You must have a privileged bind and pass your credentials to UCB::LDAP.authenticate()
    ***REMOVED*** before performing your Service search.
    ***REMOVED***
    class Service < Entry
      @entity_name = 'personService'
      @tree_base = 'ou=services,dc=berkeley,dc=edu'
      
      def eligible_by
        berkeleyEduPersonServiceEligibleBy
      end

      def eligible_date
        berkeleyEduPersonServiceEligibleDate
      end
      
      def ended_by
        berkeleyEduPersonServiceEndBy
      end

      def end_date
        berkeleyEduPersonServiceEndDate
      end

      def entered_by
        berkeleyEduPersonServiceEnteredBy
      end

      def entered_date
        berkeleyEduPersonServiceEnteredDate
      end
      
      def level
        berkeleyEduPersonServiceLevel
      end

      def modified_by
        berkeleyEduPersonServiceModifiedBy
      end

      def modified_date
        berkeleyEduPersonServiceModifiedDate
      end

      def naughty_bit
        berkeleyEduPersonServiceNaughtyBit
      end

      def notified_by
        berkeleyEduPersonServiceNotifyBy
      end

      def notify_date
        berkeleyEduPersonServiceNotifyDate
      end

      def stopped_by
        berkeleyEduPersonServiceStopBy
      end

      def stop_date
        berkeleyEduPersonServiceStopDate
      end
      
      def value
        berkeleyEduPersonServiceValue
      end

      def service
        berkeleyEduService
      end

      def common_name
        cn
      end

      def description
        super.first
      end
      
      class << self
        ***REMOVED******REMOVED***
        ***REMOVED*** Returns an Array of JobAppointment for <tt>uid</tt>, sorted by
        ***REMOVED*** record_number().
        ***REMOVED*** Returns an empty Array ([]) if nothing is found.  
        ***REMOVED***
        def find_by_uid(uid)
          base = "uid=***REMOVED***{uid},ou=people,dc=berkeley,dc=edu"
          filter = Net::LDAP::Filter.eq("objectclass", 'berkeleyEduPersonService')
          search(:base => base, :filter => filter)
        end
      end
    end
  end
end
