module ThinkingSphinx
  ***REMOVED*** Association tracks a specific reflection and join to reference data that
  ***REMOVED*** isn't in the base model. Very much an internal class for Thinking Sphinx -
  ***REMOVED*** perhaps because I feel it's not as strong (or simple) as most of the rest.
  ***REMOVED*** 
  class Association
    attr_accessor :parent, :reflection, :join
    
    ***REMOVED*** Create a new association by passing in the parent association, and the
    ***REMOVED*** corresponding reflection instance. If there is no parent, pass in nil.
    ***REMOVED*** 
    ***REMOVED***   top   = Association.new nil, top_reflection
    ***REMOVED***   child = Association.new top, child_reflection
    ***REMOVED*** 
    def initialize(parent, reflection)
      @parent, @reflection = parent, reflection
      @children = {}
    end
    
    ***REMOVED*** Get the children associations for a given association name. The only time
    ***REMOVED*** that there'll actually be more than one association is when the
    ***REMOVED*** relationship is polymorphic. To keep things simple though, it will always
    ***REMOVED*** be an Array that gets returned (an empty one if no matches).
    ***REMOVED***
    ***REMOVED***   ***REMOVED*** where pages is an association on the class tied to the reflection.
    ***REMOVED***   association.children(:pages)
    ***REMOVED*** 
    def children(assoc)
      @children[assoc] ||= Association.children(@reflection.klass, assoc, self)
    end
    
    ***REMOVED*** Get the children associations for a given class, association name and
    ***REMOVED*** parent association. Much like the instance method of the same name, it
    ***REMOVED*** will return an empty array if no associations have the name, and only
    ***REMOVED*** have multiple association instances if the underlying relationship is
    ***REMOVED*** polymorphic.
    ***REMOVED*** 
    ***REMOVED***   Association.children(User, :pages, user_association)
    ***REMOVED*** 
    def self.children(klass, assoc, parent=nil)
      ref = klass.reflect_on_association(assoc)
      
      return [] if ref.nil?
      return [Association.new(parent, ref)] unless ref.options[:polymorphic]
      
      ***REMOVED*** association is polymorphic - create associations for each
      ***REMOVED*** non-polymorphic reflection.
      polymorphic_classes(ref).collect { |klass|
        Association.new parent, ::ActiveRecord::Reflection::AssociationReflection.new(
          ref.macro,
          "***REMOVED***{ref.name}_***REMOVED***{klass.name}".to_sym,
          casted_options(klass, ref),
          ref.active_record
        )
      }
    end
    
    ***REMOVED*** Link up the join for this model from a base join - and set parent
    ***REMOVED*** associations' joins recursively.
    ***REMOVED***
    def join_to(base_join)
      parent.join_to(base_join) if parent && parent.join.nil?
      
      @join ||= ::ActiveRecord::Associations::ClassMethods::JoinDependency::JoinAssociation.new(
        @reflection, base_join, parent ? parent.join : base_join.joins.first
      )
    end
    
    ***REMOVED*** Returns the association's join SQL statements - and it replaces
    ***REMOVED*** ::ts_join_alias:: with the aliased table name so the generated reflection
    ***REMOVED*** join conditions avoid column name collisions.
    ***REMOVED*** 
    def to_sql
      @join.association_join.gsub(/::ts_join_alias::/,
        "***REMOVED***{@reflection.klass.connection.quote_table_name(@join.parent.aliased_table_name)}"
      )
    end
    
    ***REMOVED*** Returns true if the association - or a parent - is a has_many or
    ***REMOVED*** has_and_belongs_to_many.
    ***REMOVED*** 
    def is_many?
      case @reflection.macro
      when :has_many, :has_and_belongs_to_many
        true
      else
        @parent ? @parent.is_many? : false
      end
    end
    
    ***REMOVED*** Returns an array of all the associations that lead to this one - starting
    ***REMOVED*** with the top level all the way to the current association object.
    ***REMOVED*** 
    def ancestors
      (parent ? parent.ancestors : []) << self
    end
    
    def has_column?(column)
      @reflection.klass.column_names.include?(column.to_s)
    end
    
    def primary_key_from_reflection
      if @reflection.options[:through]
        @reflection.source_reflection.options[:foreign_key] ||
        @reflection.source_reflection.primary_key_name
      elsif @reflection.macro == :has_and_belongs_to_many
        @reflection.association_foreign_key
      else
        nil
      end
    end
    
    def table
      if @reflection.options[:through] ||
        @reflection.macro == :has_and_belongs_to_many
        @join.aliased_join_table_name
      else
        @join.aliased_table_name
      end
    end
    
    private
    
    ***REMOVED*** Returns all the objects that could be currently instantiated from a
    ***REMOVED*** polymorphic association. This is pretty damn fast if there's an index on
    ***REMOVED*** the foreign type column - but if there isn't, it can take a while if you
    ***REMOVED*** have a lot of data.
    ***REMOVED*** 
    def self.polymorphic_classes(ref)
      ref.active_record.connection.select_all(
        "SELECT DISTINCT ***REMOVED***{ref.options[:foreign_type]} " +
        "FROM ***REMOVED***{ref.active_record.table_name} " +
        "WHERE ***REMOVED***{ref.options[:foreign_type]} IS NOT NULL"
      ).collect { |row|
        row[ref.options[:foreign_type]].constantize
      }
    end
    
    ***REMOVED*** Returns a new set of options for an association that mimics an existing
    ***REMOVED*** polymorphic relationship for a specific class. It adds a condition to
    ***REMOVED*** filter by the appropriate object.
    ***REMOVED*** 
    def self.casted_options(klass, ref)
      options = ref.options.clone
      options[:polymorphic]   = nil
      options[:class_name]    = klass.name
      options[:foreign_key] ||= "***REMOVED***{ref.name}_id"
      
      quoted_foreign_type = klass.connection.quote_column_name ref.options[:foreign_type]
      case options[:conditions]
      when nil
        options[:conditions] = "::ts_join_alias::.***REMOVED***{quoted_foreign_type} = '***REMOVED***{klass.name}'"
      when Array
        options[:conditions] << "::ts_join_alias::.***REMOVED***{quoted_foreign_type} = '***REMOVED***{klass.name}'"
      when Hash
        options[:conditions].merge!(ref.options[:foreign_type] => klass.name)
      else
        options[:conditions] << " AND ::ts_join_alias::.***REMOVED***{quoted_foreign_type} = '***REMOVED***{klass.name}'"
      end
      
      options
    end
  end
end