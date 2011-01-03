
module UCB
  module LDAP
    ***REMOVED*** = UCB::LDAP::StudentTerm
    ***REMOVED*** 
    ***REMOVED*** This class models a student's term entries in the UCB LDAP directory.
    ***REMOVED***
    ***REMOVED***   terms = StudentTerm.find_by_uid("1234")       ***REMOVED***=> [***REMOVED***<UCB::LDAP::StudentTerm: ...>, ...]
    ***REMOVED***
    ***REMOVED*** StudentTerms are usually loaded through a Person instance:
    ***REMOVED***
    ***REMOVED***   p = Person.find_by_uid("1234")    ***REMOVED***=> ***REMOVED***<UCB::LDAP::Person: ...>
    ***REMOVED***   terms = p.student_terms        ***REMOVED***=> [***REMOVED***<UCB::LDAP::StudentTerm: ...>, ...]
    ***REMOVED***
    ***REMOVED*** == Note on Binds
    ***REMOVED*** 
    ***REMOVED*** You must have a privileged bind and pass your credentials to UCB::LDAP.authenticate()
    ***REMOVED*** before performing your StudentTerm search.
    ***REMOVED***
    class StudentTerm < Entry
      @entity_name = 'personStudentTerm'

      def change_datetime
        UCB::LDAP.local_datetime_parse(berkeleyEduStuChangeDate)
      end
      
      def college_code
        berkeleyEduStuCollegeCode
      end
      
      def college_name
        berkeleyEduStuCollegeName
      end
      
      def level_code
        berkeleyEduStuEduLevelCode
      end
      
      def level_name
        berkeleyEduStuEduLevelName
      end
      
      def role_code
        berkeleyEduStuEduRoleCode
      end
      
      def role_name
        berkeleyEduStuEduRoleName
      end
      
      def major_code
        berkeleyEduStuMajorCode
      end
      
      def major_name
        berkeleyEduStuMajorName
      end
      
      def registration_status_code
        berkeleyEduStuRegStatCode
      end
      
      def registration_status_name
        berkeleyEduStuRegStatName
      end
      
      def term_code
        berkeleyEduStuTermCode
      end
      
      def term_name
        berkeleyEduStuTermName
      end
      
      def term_status
        berkeleyEduStuTermStatus
      end
      
      def term_year
        berkeleyEduStuTermYear
      end
      
      def under_graduate_code
        berkeleyEduStuUGCode
      end
      
      class << self
        ***REMOVED*** Returns an Array of JobAppointment for <tt>uid</tt>, sorted by
        ***REMOVED*** record_number().
        ***REMOVED*** Returns an empty Array ([]) if nothing is found.  
        ***REMOVED***
        def find_by_uid(uid)
          base = "uid=***REMOVED***{uid},ou=people,dc=berkeley,dc=edu"
          filter = Net::LDAP::Filter.eq("objectclass", 'berkeleyEduPersonTerm')
          search(:base => base, :filter => filter)
        end
         
      end
    end
  end
end