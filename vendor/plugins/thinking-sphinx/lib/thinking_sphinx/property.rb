module ThinkingSphinx
  class Property
    attr_accessor :alias, :columns, :associations, :model, :faceted, :admin
    
    def initialize(source, columns, options = {})
      @source       = source
      @model        = source.model
      @columns      = Array(columns)
      @associations = {}

      raise "Cannot define a field or attribute in ***REMOVED***{source.model.name} with no columns. Maybe you are trying to index a field with a reserved name (id, name). You can fix this error by using a symbol rather than a bare name (:id instead of id)." if @columns.empty? || @columns.any? { |column| !column.respond_to?(:__stack) }
      
      @alias    = options[:as]
      @faceted  = options[:facet]
      @admin    = options[:admin]
      
      @alias    = @alias.to_sym unless @alias.blank?
      
      @columns.each { |col|
        @associations[col] = association_stack(col.__stack.clone).each { |assoc|
          assoc.join_to(source.base)
        }
      }
    end
    
    ***REMOVED*** Returns the unique name of the attribute - which is either the alias of
    ***REMOVED*** the attribute, or the name of the only column - if there is only one. If
    ***REMOVED*** there isn't, there should be an alias. Else things probably won't work.
    ***REMOVED*** Consider yourself warned.
    ***REMOVED*** 
    def unique_name
      if @columns.length == 1
        @alias || @columns.first.__name
      else
        @alias
      end
    end
    
    def to_facet
      return nil unless @faceted
      
      ThinkingSphinx::Facet.new(self)
    end
    
    ***REMOVED*** Get the part of the GROUP BY clause related to this attribute - if one is
    ***REMOVED*** needed. If not, all you'll get back is nil. The latter will happen if
    ***REMOVED*** there isn't actually a real column to get data from, or if there's
    ***REMOVED*** multiple data values (read: a has_many or has_and_belongs_to_many
    ***REMOVED*** association).
    ***REMOVED*** 
    def to_group_sql
      case
      when is_many?, is_string?, ThinkingSphinx.use_group_by_shortcut?
        nil
      else
        @columns.collect { |column|
          column_with_prefix(column)
        }
      end
    end
    
    def changed?(instance)
      return true if is_string? || @columns.any? { |col| !col.__stack.empty? }
      
      !@columns.all? { |col|
        instance.respond_to?("***REMOVED***{col.__name.to_s}_changed?") &&
        !instance.send("***REMOVED***{col.__name.to_s}_changed?")
      }
    end
    
    def admin?
      admin
    end
    
    def public?
      !admin
    end
    
    private
    
    ***REMOVED*** Could there be more than one value related to the parent record? If so,
    ***REMOVED*** then this will return true. If not, false. It's that simple.
    ***REMOVED*** 
    def is_many?
      associations.values.flatten.any? { |assoc| assoc.is_many? }
    end
    
    ***REMOVED*** Returns true if any of the columns are string values, instead of database
    ***REMOVED*** column references.
    def is_string?
      columns.all? { |col| col.is_string? }
    end
    
    def adapter
      @adapter ||= @model.sphinx_database_adapter
    end
    
    def quote_with_table(table, column)
      "***REMOVED***{quote_table_name(table)}.***REMOVED***{quote_column(column)}"
    end
    
    def quote_column(column)
      @model.connection.quote_column_name(column)
    end
    
    def quote_table_name(table_name)
      @model.connection.quote_table_name(table_name)
    end
    
    ***REMOVED*** Indication of whether the columns should be concatenated with a space
    ***REMOVED*** between each value. True if there's either multiple sources or multiple
    ***REMOVED*** associations.
    ***REMOVED*** 
    def concat_ws?
      multiple_associations? || @columns.length > 1
    end
        
    ***REMOVED*** Checks whether any column requires multiple associations (which only
    ***REMOVED*** happens for polymorphic situations).
    ***REMOVED*** 
    def multiple_associations?
      associations.any? { |col,assocs| assocs.length > 1 }
    end
    
    ***REMOVED*** Builds a column reference tied to the appropriate associations. This
    ***REMOVED*** dives into the associations hash and their corresponding joins to
    ***REMOVED*** figure out how to correctly reference a column in SQL.
    ***REMOVED*** 
    def column_with_prefix(column)
      if column.is_string?
        column.__name
      elsif associations[column].empty?
        "***REMOVED***{@model.quoted_table_name}.***REMOVED***{quote_column(column.__name)}"
      else
        associations[column].collect { |assoc|
          assoc.has_column?(column.__name) ?
          "***REMOVED***{quote_with_table(assoc.join.aliased_table_name, column.__name)}" :
          nil
        }.compact
      end
    end
    
    def columns_with_prefixes
      @columns.collect { |column|
        column_with_prefix column
      }.flatten
    end
    
    ***REMOVED*** Gets a stack of associations for a specific path.
    ***REMOVED*** 
    def association_stack(path, parent = nil)
      assocs = []
      
      if parent.nil?
        assocs = @source.association(path.shift)
      else
        assocs = parent.children(path.shift)
      end
      
      until path.empty?
        point  = path.shift
        assocs = assocs.collect { |assoc| assoc.children(point) }.flatten
      end
      
      assocs
    end
  end
end
