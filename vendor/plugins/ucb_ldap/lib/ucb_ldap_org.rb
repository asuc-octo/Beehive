
module UCB
  module LDAP
    ***REMOVED******REMOVED***
    ***REMOVED*** =UCB::LDAP::Org
    ***REMOVED***
    ***REMOVED*** Class for accessing the Org Unit tree of the UCB LDAP directory.
    ***REMOVED*** 
    ***REMOVED*** You can search by specifying your own filter:
    ***REMOVED*** 
    ***REMOVED***   e = Org.search(:filter => 'ou=jkasd')
    ***REMOVED***   
    ***REMOVED*** But most of the time you'll use the find_by_ou() method:
    ***REMOVED*** 
    ***REMOVED***   e = Org.find_by_ou('jkasd')
    ***REMOVED***   
    ***REMOVED*** Get attribute values as if the attribute names were instance methods.
    ***REMOVED*** Values returned reflect the cardinality and type as specified in the
    ***REMOVED*** LDAP schema.
    ***REMOVED*** 
    ***REMOVED***   e = Org.find_by_ou('jkasd')
    ***REMOVED***   
    ***REMOVED***   e.ou                                 ***REMOVED***=> ['JKASD']
    ***REMOVED***   e.description                        ***REMOVED***=> ['Application Services']
    ***REMOVED***   e.berkeleyEduOrgUnitProcessUnitFlag  ***REMOVED***=> true
    ***REMOVED***   
    ***REMOVED*** Convenience methods are provided that have friendlier names
    ***REMOVED*** and return scalars for attributes the schema says are mulit-valued,
    ***REMOVED*** but in practice are single-valued:
    ***REMOVED*** 
    ***REMOVED***   e = Org.find_by_ou('jkasd')
    ***REMOVED***   
    ***REMOVED***   e.deptid                      ***REMOVED***=> 'JKASD'
    ***REMOVED***   e.name                        ***REMOVED***=> 'Application Services'
    ***REMOVED***   e.processing_unit?            ***REMOVED***=> true
    ***REMOVED***
    ***REMOVED*** Other methods encapsulate common processing:
    ***REMOVED***
    ***REMOVED***   e.level                       ***REMOVED***=> 4
    ***REMOVED***   e.parent_node                 ***REMOVED***=> ***REMOVED***<UCB::LDAP::Org: ...>
    ***REMOVED***   e.parent_node.deptid          ***REMOVED***=> 'VRIST'
    ***REMOVED***   e.child_nodes                 ***REMOVED***=> [***REMOVED***<UCB::LDAP::Org: ..>, ...]
    ***REMOVED***
    ***REMOVED*** 
    ***REMOVED*** You can retrieve people in a department.  This will be
    ***REMOVED*** an +Array+ of UCB::LDAP::Person.
    ***REMOVED*** 
    ***REMOVED***   asd = Org.find_by_ou('jkasd')
    ***REMOVED***   
    ***REMOVED***   asd_staff = asd.persons       ***REMOVED***=> [***REMOVED***<UCB::LDAP::Person: ...>, ...]
    ***REMOVED***
    ***REMOVED*** === Getting a Node's Level "n" Code or Name
    ***REMOVED*** 
    ***REMOVED*** There are methods that will return the org code and org name
    ***REMOVED*** at a particular level.  They are implemented by method_missing
    ***REMOVED*** and so are not documented in the instance method section.
    ***REMOVED***
    ***REMOVED***   o = Org.find_by_ou('jkasd')
    ***REMOVED***
    ***REMOVED***   o.code          ***REMOVED***=> 'JKASD'
    ***REMOVED***   o.level         ***REMOVED***=> 4
    ***REMOVED***   o.level_4_code  ***REMOVED***=> 'JKASD'
    ***REMOVED***   o.level_3_name  ***REMOVED***=> 'Info Services & Technology'
    ***REMOVED***   o.level_2_code  ***REMOVED***=> 'AVCIS'
    ***REMOVED***   o.level_5_code  ***REMOVED***=> nil
    ***REMOVED***
    ***REMOVED*** == Dealing With the Entire Org Tree
    ***REMOVED***
    ***REMOVED*** There are several class methods that simplify most operations
    ***REMOVED*** involving the entire org tree.
    ***REMOVED***
    ***REMOVED*** === Org.all_nodes()
    ***REMOVED***
    ***REMOVED*** Returns a +Hash+ of all org nodes whose keys are deptids
    ***REMOVED*** and whose values are corresponding Org instances.
    ***REMOVED***
    ***REMOVED***   ***REMOVED*** List all nodes alphabetically by department name
    ***REMOVED***   
    ***REMOVED***   nodes_by_name = Org.all_nodes.values.sort_by{|n| n.name.upcase}
    ***REMOVED***   nodes_by_name.each do |n|
    ***REMOVED***     puts "***REMOVED***{n.deptid} - ***REMOVED***{n.name}"
    ***REMOVED***   end 
    ***REMOVED***
    ***REMOVED*** === Org.flattened_tree()
    ***REMOVED***
    ***REMOVED*** Returns an +Array+ of all nodes in hierarchy order.
    ***REMOVED*** 
    ***REMOVED***   UCB::LDAP::Org.flattened_tree.each do |node|
    ***REMOVED***     puts "***REMOVED***{node.level} ***REMOVED***{node.deptid} - ***REMOVED***{node.name}"
    ***REMOVED***   end
    ***REMOVED***   
    ***REMOVED*** Produces:
    ***REMOVED*** 
    ***REMOVED***   1 UCBKL - UC Berkeley Campus
    ***REMOVED***   2 AVCIS - Information Sys & Technology
    ***REMOVED***   3 VRIST - Info Systems & Technology
    ***REMOVED***   4 JFAVC - Office of the CIO
    ***REMOVED***   5 JFADM - Assoc VC Off General Ops
    ***REMOVED***   4 JGMIP - Museum Informatics Project
    ***REMOVED***   4 JHSSC - Social Sci Computing Lab    
    ***REMOVED***   etc.
    ***REMOVED***   
    ***REMOVED*** === Org.root_node()
    ***REMOVED***
    ***REMOVED*** Returns the root node in the Org Tree.
    ***REMOVED*** 
    ***REMOVED*** By recursing down child_nodes you can access the entire
    ***REMOVED*** org tree:
    ***REMOVED*** 
    ***REMOVED***   ***REMOVED*** display deptid, name and children recursively
    ***REMOVED***   def display_node(node)
    ***REMOVED***     indent = "  " * (node.level - 1)
    ***REMOVED***     puts "***REMOVED***{indent} ***REMOVED***{node.deptid} - ***REMOVED***{node.name}"
    ***REMOVED***     node.child_nodes.each{|child| display_node(child)}
    ***REMOVED***   end
    ***REMOVED***  
    ***REMOVED***   ***REMOVED*** start at root node
    ***REMOVED***   display_node(Org.root_node)
    ***REMOVED***
    ***REMOVED*** == Caching of Search Results
    ***REMOVED*** 
    ***REMOVED*** Calls to any of the following class methods automatically cache
    ***REMOVED*** the entire Org tree:
    ***REMOVED*** 
    ***REMOVED*** * all_nodes()
    ***REMOVED*** * flattened_tree()
    ***REMOVED*** * root_node()
    ***REMOVED***
    ***REMOVED*** Subsequent calls to any of these methods return the results from
    ***REMOVED*** cache and don't require another LDAP query.
    ***REMOVED***
    ***REMOVED*** Subsequent calls to find_by_ou() are done
    ***REMOVED*** against the local cache.  Searches done via the ***REMOVED***search()
    ***REMOVED*** method do <em>not</em> use the local cache.
    ***REMOVED***
    ***REMOVED*** Force loading of the cache by calling load_all_nodes().
    ***REMOVED***
    class Org < Entry
      @entity_name = "org"
      @tree_base = 'ou=org units,dc=berkeley,dc=edu'
      
      ***REMOVED******REMOVED***
      ***REMOVED*** Returns <tt>Array</tt> of child nodes, each an instance of Org,
      ***REMOVED*** sorted by department id.
      ***REMOVED***
      def child_nodes()
        @sorted_child_nodes ||= load_child_nodes.sort_by { |node| node.deptid }
      end
      
      ***REMOVED******REMOVED***
      ***REMOVED*** Returns the department id.
      ***REMOVED***
      def deptid()
        ou.first
      end
      alias :code :deptid

      ***REMOVED******REMOVED***
      ***REMOVED*** Returns the entry's level in the Org Tree.
      ***REMOVED***
      def level()
        @level ||= parent_deptids.size + 1
      end
      
      ***REMOVED******REMOVED***
      ***REMOVED*** Returns the department name.
      ***REMOVED***
      def name()
        description.first
      end

      ***REMOVED******REMOVED***
      ***REMOVED*** Returns parent node's deptid
      ***REMOVED***
      def parent_deptid()
        @parent_deptid ||= parent_deptids.last
      end

      ***REMOVED******REMOVED***
      ***REMOVED*** Returns Array of parent deptids.
      ***REMOVED*** 
      ***REMOVED*** Highest level is first element; immediate parent is last element.
      ***REMOVED***
      def parent_deptids()
        return @parent_deptids if @parent_deptids
        hierarchy_array = berkeleyEduOrgUnitHierarchyString.split("-")
        hierarchy_array.pop  ***REMOVED*** last element is deptid ... toss it
        @parent_deptids = hierarchy_array
      end

      ***REMOVED******REMOVED***
      ***REMOVED*** Returns +true+ if org is a processing unit.
      ***REMOVED***
      def processing_unit?()
        berkeleyEduOrgUnitProcessUnitFlag
      end

      ***REMOVED******REMOVED***
      ***REMOVED*** Return parent node which is an instance of Org.
      ***REMOVED***
      def parent_node()
        return nil if parent_deptids.size == 0
        @parent_node ||= UCB::LDAP::Org.find_by_ou parent_deptid
      end

      ***REMOVED******REMOVED***
      ***REMOVED*** Returns <tt>Array</tt> of parent nodes which are instances of Org.
      ***REMOVED***
      def parent_nodes()
        @parent_nodes ||= parent_deptids.map { |deptid| UCB::LDAP::Org.find_by_ou(deptid) }
      end

      ***REMOVED******REMOVED***
      ***REMOVED*** Support for method names like level_2_code, level_2_name
      ***REMOVED***
      def method_missing(method, *args) ***REMOVED***:nodoc:
        return code_or_name_at_level($1, $2) if method.to_s =~ /^level_([1-6])_(code|name)$/
        super
      end

      ***REMOVED******REMOVED***
      ***REMOVED*** Return the level "n" code or name.  Returns nil if level > self.level.
      ***REMOVED*** Called from method_messing().
      ***REMOVED***
      def code_or_name_at_level(level, code_or_name) ***REMOVED***:nodoc:
        return (code_or_name == 'code' ? code : name) if level.to_i == self.level
        element = level.to_i - 1
        return parent_deptids[element] if code_or_name == 'code'
        parent_nodes[element] && parent_nodes[element].name
      end
      
      ***REMOVED******REMOVED***
      ***REMOVED*** Returns <tt>Array</tt> of UCB::LDAP::Person instances for each person
      ***REMOVED*** in the org node.
      ***REMOVED***
      def persons()
        @persons ||= UCB::LDAP::Person.search(:filter => {:departmentnumber => ou})
      end
      alias :people :persons
      
      ***REMOVED***---
      ***REMOVED*** Must be public for load_all_nodes()
      def init_child_nodes() ***REMOVED***:nodoc:
        @child_nodes = []
      end

      ***REMOVED***---
      ***REMOVED*** Add node to child node array.
      def push_child_node(child_node)***REMOVED***:nodoc:
        @child_nodes ||= []
        unless @child_nodes.find { |n| n.ou == child_node.ou }
          @child_nodes.push(child_node)
        end
      end

      private unless $TESTING
      
      ***REMOVED******REMOVED***
      ***REMOVED*** Loads child nodes for individual node.  If all_nodes_nodes()
      ***REMOVED*** has been called, child nodes are all loaded/calculated.
      ***REMOVED***
      def load_child_nodes
        @child_nodes ||= UCB::LDAP::Org.search(:scope => 1, :base => dn, :filter => {:ou => '*'})
      end
      
      ***REMOVED******REMOVED***
      ***REMOVED*** Access to instance variables for testing
      ***REMOVED***
      def child_nodes_i()
        @child_nodes
      end


      class << self
        public
        
        ***REMOVED******REMOVED***
        ***REMOVED*** Rebuild the org tree using fresh data from ldap
        ***REMOVED***
        def rebuild_node_cache
          clear_all_nodes
          load_all_nodes
        end
        
        ***REMOVED******REMOVED***
        ***REMOVED*** Returns a +Hash+ of all org nodes whose keys are deptids
        ***REMOVED*** and whose values are corresponding Org instances.
        ***REMOVED***
        def all_nodes()
          @all_nodes ||= load_all_nodes
        end
        
        ***REMOVED******REMOVED***
        ***REMOVED*** Returns an instance of Org for the matching _ou_.
        ***REMOVED***
        def find_by_ou(ou)
          find_by_ou_from_cache(ou) || search(:filter => {:ou => ou}).first
        end

        ***REMOVED******REMOVED***
        ***REMOVED*** for backwards compatibility -- should be deprecated
        ***REMOVED***
        alias :org_by_ou :find_by_ou

        ***REMOVED******REMOVED***
        ***REMOVED*** Returns an +Array+ of all nodes in hierarchy order.  If you call
        ***REMOVED*** with <tt>:level</tt> option, only nodes down to that level are
        ***REMOVED*** returned.
        ***REMOVED***
        ***REMOVED***   Org.flattened_tree               ***REMOVED*** returns all nodes
        ***REMOVED***   Org.flattened_tree(:level => 3)  ***REMOVED*** returns down to level 3
        ***REMOVED***
        def flattened_tree(options={})
          @flattened_tree ||= build_flattened_tree
          return @flattened_tree unless options[:level]
          @flattened_tree.reject { |o| o.level > options[:level] }
        end
        
        ***REMOVED******REMOVED***
        ***REMOVED*** Loads all org nodes and stores them in Hash returned by all_nodes().
        ***REMOVED*** Subsequent calls to find_by_ou() will be from cache and not 
        ***REMOVED*** require a trip to the LDAP server.
        ***REMOVED***
        def load_all_nodes()
          return @all_nodes if @all_nodes
          return nodes_from_test_cache if $TESTING && @test_node_cache
          
          bind_for_whole_tree
          @all_nodes = search.inject({}) do |accum, org|            
            accum[org.deptid] = org if org.deptid != "Org Units"
            accum
          end
          
          build_test_node_cache if $TESTING
          calculate_all_child_nodes
          UCB::LDAP.clear_authentication
          @all_nodes
        end
        
        ***REMOVED******REMOVED***
        ***REMOVED*** Returns the root node in the Org Tree.
        ***REMOVED***
        def root_node()
          load_all_nodes
          find_by_ou('UCBKL')
        end

        private unless $TESTING

        ***REMOVED******REMOVED***
        ***REMOVED*** Use bind that allows for retreiving entire org tree in one search.
        ***REMOVED***
        def bind_for_whole_tree()
          username = "uid=istaswa-ruby,ou=applications,dc=berkeley,dc=edu"
          password = "t00lBox12"
          UCB::LDAP.authenticate(username, password)
        end
        
        ***REMOVED******REMOVED***
        ***REMOVED*** Returns an instance of Org from the local if cache exists, else +nil+.
        ***REMOVED***
        def find_by_ou_from_cache(ou) ***REMOVED***:nodoc:
          return nil if ou.nil?
          return nil unless @all_nodes
          @all_nodes[ou.upcase]
        end
        
        ***REMOVED******REMOVED***
        ***REMOVED*** Returns cached nodes if we are testing and have already 
        ***REMOVED*** fetched all the nodes.
        ***REMOVED***
        def nodes_from_test_cache()
          @all_nodes = {}
          @test_node_cache.each { |k, v| @all_nodes[k] = v.clone }
          calculate_all_child_nodes
          @all_nodes
        end
        
        ***REMOVED******REMOVED***
        ***REMOVED*** Build cache of all nodes.  Only used during testing.
        ***REMOVED***
        def build_test_node_cache()
          @test_node_cache = {}
          @all_nodes.each { |k, v| @test_node_cache[k] = v.clone }
        end
        
        ***REMOVED******REMOVED***
        ***REMOVED*** Will calculate child_nodes for every node.
        ***REMOVED***
        def calculate_all_child_nodes()
          @all_nodes.values.each { |node| node.init_child_nodes }
          @all_nodes.values.each do |node|
            next if node.deptid == 'UCBKL' || node.deptid == "Org Units"
            parent_node = find_by_ou_from_cache(node.parent_deptids.last)
            parent_node.push_child_node(node)
          end
        end
        
        ***REMOVED******REMOVED***
        ***REMOVED*** Builds flattened tree.  See RDoc for flattened_tree() for details.
        ***REMOVED***
        def build_flattened_tree()
          load_all_nodes
          @flattened_tree = []
          add_to_flattened_tree UCB::LDAP::Org.root_node
          @flattened_tree
        end
        
        ***REMOVED******REMOVED***
        ***REMOVED*** Adds a node and its children to @flattened_tree.
        ***REMOVED***
        def add_to_flattened_tree(node)
          @flattened_tree.push node
          node.child_nodes.each { |child| add_to_flattened_tree child }
        end
      
        ***REMOVED*** Direct access to instance variables for unit testing
        
        def all_nodes_i()
          @all_nodes
        end
        
        def clear_all_nodes()
          @all_nodes = nil
        end
      end
    end
  end 
end
