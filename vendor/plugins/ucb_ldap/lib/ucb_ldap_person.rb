
module UCB::LDAP
  ***REMOVED******REMOVED***
  ***REMOVED*** =UCB::LDAP::Person
  ***REMOVED***
  ***REMOVED*** Class for accessing the People tree of the UCB LDAP directory.
  ***REMOVED*** 
  ***REMOVED*** You can search by specifying your own filter:
  ***REMOVED*** 
  ***REMOVED***   e = Person.search(:filter => {:uid => 123})
  ***REMOVED***   
  ***REMOVED*** Or you can use a convenience search method:
  ***REMOVED*** 
  ***REMOVED***   e = Person.find_by_uid("123")
  ***REMOVED***   
  ***REMOVED*** Access attributes as if they were instance methods:  
  ***REMOVED*** 
  ***REMOVED***   e = Person.find_by_uid("123")
  ***REMOVED***   
  ***REMOVED***   e.givenname    ***REMOVED***=> "John"
  ***REMOVED***   e.sn           ***REMOVED***=> "Doe"
  ***REMOVED***   
  ***REMOVED*** Methods with friendly names are provided for accessing attribute values:
  ***REMOVED*** 
  ***REMOVED***   e = Person.person_by_uid("123")
  ***REMOVED***   
  ***REMOVED***   e.firstname    ***REMOVED***=> "John"
  ***REMOVED***   e.lastname     ***REMOVED***=> "Doe"
  ***REMOVED*** 
  ***REMOVED*** There are other convenience methods:
  ***REMOVED*** 
  ***REMOVED***   e = Person.person_by_uid("123")
  ***REMOVED***   
  ***REMOVED***   e.affiliations        ***REMOVED***=> ["EMPLOYEE-TYPE-STAFF"]
  ***REMOVED***   e.employee?           ***REMOVED***=> true
  ***REMOVED***   e.employee_staff?     ***REMOVED***=> true
  ***REMOVED***   e.employee_academic?  ***REMOVED***=> false
  ***REMOVED***   e.student?            ***REMOVED***=> false
  ***REMOVED*** 
  ***REMOVED*** == Other Parts of the Tree
  ***REMOVED***
  ***REMOVED*** You can access other parts of the LDAP directory through Person
  ***REMOVED*** instances:
  ***REMOVED***
  ***REMOVED***   p = Person.find_by_uid("123")
  ***REMOVED***
  ***REMOVED***   p.org_node          ***REMOVED***=> Org
  ***REMOVED***   p.affiliations      ***REMOVED***=> Array of Affiliation
  ***REMOVED***   p.addresses         ***REMOVED***=> Array of Address
  ***REMOVED***   p.job_appointments  ***REMOVED***=> Array of JobAppointment
  ***REMOVED***   p.namespaces        ***REMOVED***=> Array of Namespace
  ***REMOVED***   p.student_terms     ***REMOVED***=> Array of StudentTerm
  ***REMOVED***
  ***REMOVED*** ==Attributes
  ***REMOVED*** 
  ***REMOVED*** See Ldap::Entry for general information on accessing attribute values.
  ***REMOVED***
  class Person < Entry
    class RecordNotFound < StandardError; end
    
    include AffiliationMethods
    include GenericAttributes
    
    @entity_name = 'person'
    @tree_base = 'ou=people,dc=berkeley,dc=edu'
    
    class << self
      ***REMOVED******REMOVED***
      ***REMOVED*** Returns an instance of Person for given _uid_.
      ***REMOVED***
      def find_by_uid(uid)
        uid = uid.to_s
        find_by_uids([uid]).first
      end
      alias :person_by_uid :find_by_uid  
      
      ***REMOVED******REMOVED***
      ***REMOVED*** Returns an +Array+ of Person for given _uids_.
      ***REMOVED***
      def find_by_uids(uids)
        return [] if uids.size == 0
        filters = uids.map{|uid| Net::LDAP::Filter.eq("uid", uid)}
        search(:filter => self.combine_filters(filters, '|'))
      end
      alias :persons_by_uids :find_by_uids 

      ***REMOVED******REMOVED***
      ***REMOVED*** Exclude test entries from search results unless told otherwise.
      ***REMOVED***
      def search(args) ***REMOVED***:nodoc:
        results = super
        include_test_entries? ? results : results.reject { |person| person.test? }
      end

      ***REMOVED******REMOVED***
      ***REMOVED*** If <tt>true</tt> test entries are included in search results
      ***REMOVED*** (defalut is <tt>false</tt>).
      ***REMOVED***
      def include_test_entries?
        ***REMOVED*** @include_test_entries ? true : false
        true
      end

      ***REMOVED******REMOVED***
      ***REMOVED*** Setter for include_test_entries?
      ***REMOVED***
      def include_test_entries=(include_test_entries)
        @include_test_entries = include_test_entries
      end
    end

    
    def deptid
      berkeleyEduPrimaryDeptUnit
    end
    alias :dept_code :deptid
    
    def dept_name
      berkeleyEduUnitCalNetDeptName
    end
    
    ***REMOVED******REMOVED***
    ***REMOVED*** Returns +Array+ of JobAppointment for this Person.
    ***REMOVED*** Requires a bind with access to job appointments.
    ***REMOVED*** See UCB::LDAP.authenticate().
    ***REMOVED***
    def job_appointments
      @job_appointments ||= JobAppointment.find_by_uid(uid)
    end
    
    ***REMOVED******REMOVED***
    ***REMOVED*** Returns +Array+ of StudentTerm for this Person.
    ***REMOVED*** Requires a bind with access to student terms.
    ***REMOVED*** See UCB::LDAP.authenticate().
    ***REMOVED***
    def student_terms
      @student_terms ||= StudentTerm.find_by_uid(uid)
    end
    
    ***REMOVED******REMOVED***
    ***REMOVED*** Returns instance of UCB::LDAP::Org corresponding to 
    ***REMOVED*** primary department.
    ***REMOVED***
    def org_node
      @org_node ||= UCB::LDAP::Org.find_by_ou(deptid)
    end
    
  end
end
