
module UCB
  module LDAP
    ***REMOVED*** = UCB::LDAP::JobAppointment
    ***REMOVED*** 
    ***REMOVED*** This class models a person's job appointment instance in the UCB LDAP directory.
    ***REMOVED***
    ***REMOVED***   appts = JobAppontment.find_by_uid("1234")       ***REMOVED***=> [***REMOVED***<UCB::LDAP::JobAppointment: ...>, ...]
    ***REMOVED***
    ***REMOVED*** JobAppointments are usually loaded through a Person instance:
    ***REMOVED***
    ***REMOVED***   p = Person.find_by_uid("1234")    ***REMOVED***=> ***REMOVED***<UCB::LDAP::Person: ...>
    ***REMOVED***   appts = p.job_appointments        ***REMOVED***=> [***REMOVED***<UCB::LDAP::JobAppointment: ...>, ...]
    ***REMOVED***
    ***REMOVED*** == Note on Binds
    ***REMOVED*** 
    ***REMOVED*** You must have a privileged bind and pass your credentials to UCB::LDAP.authenticate()
    ***REMOVED*** before performing your JobAppointment search.
    ***REMOVED***
    class JobAppointment < Entry
      @entity_name = 'personJobAppointment'

      def cto_code
        berkeleyEduPersonJobApptCTOCode
      end
      
      def deptid
        berkeleyEduPersonJobApptDepartment
      end
      
      def record_number
        berkeleyEduPersonJobApptEmpRecNumber.to_i
      end
      
      def personnel_program_code
        berkeleyEduPersonJobApptPersPgmCode
      end
      
      def primary?
        berkeleyEduPersonJobApptPrimaryFlag
      end
      
      ***REMOVED*** Returns Employee Relation Code
      def erc_code
        berkeleyEduPersonJobApptRelationsCode
      end
      
      def represented?
        berkeleyEduPersonJobApptRepresentation != 'U'
      end
      
      def title_code
        berkeleyEduPersonJobApptTitleCode
      end
      
      def appointment_type
        berkeleyEduPersonJobApptType
      end
      
      ***REMOVED*** Returns +true+ if appointment is Without Salary
      def wos?
        berkeleyEduPersonJobApptWOS
      end
      
      class << self
        ***REMOVED*** Returns an Array of JobAppointment for <tt>uid</tt>, sorted by
        ***REMOVED*** record_number().
        ***REMOVED*** Returns an empty Array ([]) if nothing is found.  
        ***REMOVED***
        def find_by_uid(uid)
          base = "uid=***REMOVED***{uid},ou=people,dc=berkeley,dc=edu"
          filter = Net::LDAP::Filter.eq("objectclass", 'berkeleyEduPersonJobAppt')
          search(:base => base, :filter => filter).sort_by{|appt| appt.record_number}
        end
         
      end
    end
  end
end