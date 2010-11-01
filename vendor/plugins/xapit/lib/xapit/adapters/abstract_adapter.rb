module Xapit
  ***REMOVED*** Adapters are used to support multiple ORMs (ActiveRecord, Datamapper, Sequel, etc.).
  ***REMOVED*** It abstracts out all find calls so they can be handled differently for each ORM.
  ***REMOVED*** To create your own adapter, subclass AbstractAdapter and override the placeholder methods.
  ***REMOVED*** See ActiveRecordAdapter for an example.
  class AbstractAdapter
    def self.inherited(subclass)
      @subclasses ||= []
      @subclasses << subclass
    end
    
    ***REMOVED*** Returns all adapter classes.
    def self.subclasses
      @subclasses
    end
    
    ***REMOVED*** Sets the @target instance, this is the class the adapter needs to forward
    ***REMOVED*** its messages to.
    def initialize(target)
      @target = target
    end
    
    ***REMOVED*** Used to determine if the given adapter should be used for the passed in class.
    ***REMOVED*** Usually one will see if it inherits from another class (ActiveRecord::Base)
    def self.for_class?(member_class)
      raise "To be implemented in subclass"
    end
    
    ***REMOVED*** Fetch a single record by the given id.
    ***REMOVED*** The args are the same as those passed from the XapitMember***REMOVED***xapit call.
    def find_single(id, *args)
      raise "To be implemented in subclass"
    end
    
    ***REMOVED*** Fetch multiple records from the passed in array of ids.
    def find_multiple(ids)
      raise "To be implemented in subclass"
    end
    
    ***REMOVED*** Iiterate through all records using the given parameters.
    ***REMOVED*** It should yield to the block and pass in each record individually.
    ***REMOVED*** The args are the same as those passed from the XapitMember***REMOVED***xapit call.
    def find_each(*args, &block)
      raise "To be implemented in subclass"
    end
  end
end
