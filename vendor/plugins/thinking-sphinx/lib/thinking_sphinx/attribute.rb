module ThinkingSphinx
  ***REMOVED*** Attributes - eternally useful when it comes to filtering, sorting or
  ***REMOVED*** grouping. This class isn't really useful to you unless you're hacking
  ***REMOVED*** around with the internals of Thinking Sphinx - but hey, don't let that
  ***REMOVED*** stop you.
  ***REMOVED***
  ***REMOVED*** One key thing to remember - if you're using the attribute manually to
  ***REMOVED*** generate SQL statements, you'll need to set the base model, and all the
  ***REMOVED*** associations. Which can get messy. Use Index.link!, it really helps.
  ***REMOVED*** 
  class Attribute < ThinkingSphinx::Property
    attr_accessor :query_source
    
    ***REMOVED*** To create a new attribute, you'll need to pass in either a single Column
    ***REMOVED*** or an array of them, and some (optional) options.
    ***REMOVED***
    ***REMOVED*** Valid options are:
    ***REMOVED*** - :as     => :alias_name
    ***REMOVED*** - :type   => :attribute_type
    ***REMOVED*** - :source => :field, :query, :ranged_query
    ***REMOVED***
    ***REMOVED*** Alias is only required in three circumstances: when there's
    ***REMOVED*** another attribute or field with the same name, when the column name is
    ***REMOVED*** 'id', or when there's more than one column.
    ***REMOVED*** 
    ***REMOVED*** Type is not required, unless you want to force a column to be a certain
    ***REMOVED*** type (but keep in mind the value will not be CASTed in the SQL
    ***REMOVED*** statements). The only time you really need to use this is when the type
    ***REMOVED*** can't be figured out by the column - ie: when not actually using a
    ***REMOVED*** database column as your source.
    ***REMOVED*** 
    ***REMOVED*** Source is only used for multi-value attributes (MVA). By default this will
    ***REMOVED*** use a left-join and a group_concat to obtain the values. For better performance
    ***REMOVED*** during indexing it can be beneficial to let Sphinx use a separate query to retrieve
    ***REMOVED*** all document,value-pairs.
    ***REMOVED*** Either :query or :ranged_query will enable this feature, where :ranged_query will cause
    ***REMOVED*** the query to be executed incremental.
    ***REMOVED***
    ***REMOVED*** Example usage:
    ***REMOVED***
    ***REMOVED***   Attribute.new(
    ***REMOVED***     Column.new(:created_at)
    ***REMOVED***   )
    ***REMOVED***
    ***REMOVED***   Attribute.new(
    ***REMOVED***     Column.new(:posts, :id),
    ***REMOVED***     :as => :post_ids
    ***REMOVED***   )
    ***REMOVED***
    ***REMOVED***   Attribute.new(
    ***REMOVED***     Column.new(:posts, :id),
    ***REMOVED***     :as => :post_ids,
    ***REMOVED***     :source => :ranged_query
    ***REMOVED***   )
    ***REMOVED***
    ***REMOVED***   Attribute.new(
    ***REMOVED***     [Column.new(:pages, :id), Column.new(:articles, :id)],
    ***REMOVED***     :as => :content_ids
    ***REMOVED***   )
    ***REMOVED***
    ***REMOVED***   Attribute.new(
    ***REMOVED***     Column.new("NOW()"),
    ***REMOVED***     :as   => :indexed_at,
    ***REMOVED***     :type => :datetime
    ***REMOVED***   )
    ***REMOVED***
    ***REMOVED*** If you're creating attributes for latitude and longitude, don't forget
    ***REMOVED*** that Sphinx expects these values to be in radians.
    ***REMOVED***  
    def initialize(source, columns, options = {})
      super
      
      @type           = options[:type]
      @query_source   = options[:source]
      @crc            = options[:crc]
      
      @type         ||= :multi    unless @query_source.nil?
      if @type == :string && @crc
        @type = is_many? ? :multi : :integer
      end
      
      source.attributes << self
    end
    
    ***REMOVED*** Get the part of the SELECT clause related to this attribute. Don't forget
    ***REMOVED*** to set your model and associations first though.
    ***REMOVED***
    ***REMOVED*** This will concatenate strings and arrays of integers, and convert
    ***REMOVED*** datetimes to timestamps, as needed.
    ***REMOVED*** 
    def to_select_sql
      return nil unless include_as_association?
      
      separator = all_ints? || all_datetimes? || @crc ? ',' : ' '
      
      clause = columns_with_prefixes.collect { |column|
        case type
        when :string
          adapter.convert_nulls(column)
        when :datetime
          adapter.cast_to_datetime(column)
        when :multi
          column = adapter.cast_to_datetime(column)   if is_many_datetimes?
          column = adapter.convert_nulls(column, '0') if is_many_ints?
          column
        else
          column
        end
      }.join(', ')
      
      clause = adapter.crc(clause)                          if @crc
      clause = adapter.concatenate(clause, separator)       if concat_ws?
      clause = adapter.group_concatenate(clause, separator) if is_many?
      
      "***REMOVED***{clause} AS ***REMOVED***{quote_column(unique_name)}"
    end
    
    def type_to_config
      {
        :multi    => :sql_attr_multi,
        :datetime => :sql_attr_timestamp,
        :string   => :sql_attr_str2ordinal,
        :float    => :sql_attr_float,
        :boolean  => :sql_attr_bool,
        :integer  => :sql_attr_uint,
        :bigint   => :sql_attr_bigint
      }[type]
    end
    
    def include_as_association?
      ! (type == :multi && (query_source == :query || query_source == :ranged_query))
    end
    
    ***REMOVED*** Returns the configuration value that should be used for
    ***REMOVED*** the attribute.
    ***REMOVED*** Special case is the multi-valued attribute that needs some
    ***REMOVED*** extra configuration. 
    ***REMOVED*** 
    def config_value(offset = nil, delta = false)
      if type == :multi
        multi_config = include_as_association? ? "field" :
          source_value(offset, delta).gsub(/\s+/m, " ").strip
        "uint ***REMOVED***{unique_name} from ***REMOVED***{multi_config}"
      else
        unique_name
      end
    end
        
    ***REMOVED*** Returns the type of the column. If that's not already set, it returns
    ***REMOVED*** :multi if there's the possibility of more than one value, :string if
    ***REMOVED*** there's more than one association, otherwise it figures out what the
    ***REMOVED*** actual column's datatype is and returns that.
    ***REMOVED*** 
    def type
      @type ||= begin
        base_type = case
        when is_many?, is_many_ints?
          :multi
        when @associations.values.flatten.length > 1
          :string
        else
          translated_type_from_database
        end
        
        if base_type == :string && @crc
          base_type = :integer
        else
          @crc = false unless base_type == :multi && is_many_strings? && @crc
        end
        
        base_type
      end
    end
    
    def updatable?
      [:integer, :datetime, :boolean].include?(type) && !is_string?
    end
    
    def live_value(instance)
      object = instance
      column = @columns.first
      column.__stack.each { |method|
        object = object.send(method)
        return sphinx_value(nil) if object.nil?
      }
      
      sphinx_value object.send(column.__name)
    end
    
    def all_ints?
      all_of_type?(:integer)
    end
    
    def all_datetimes?
      all_of_type?(:datetime, :date, :timestamp)
    end
    
    def all_strings?
      all_of_type?(:string, :text)
    end
    
    private
    
    def source_value(offset, delta)
      if is_string?
        return "***REMOVED***{query_source.to_s.dasherize}; ***REMOVED***{columns.first.__name}"
      end
      
      query = query(offset)

      if query_source == :ranged_query
        query += query_clause
        query += " AND ***REMOVED***{query_delta.strip}" if delta
        "ranged-query; ***REMOVED***{query}; ***REMOVED***{range_query}"
      else
        query += "WHERE ***REMOVED***{query_delta.strip}" if delta
        "query; ***REMOVED***{query}"
      end
    end
    
    def query(offset)
      base_assoc = base_association_for_mva
      end_assoc  = end_association_for_mva
      raise "Could not determine SQL for MVA" if base_assoc.nil?
      
      <<-SQL
SELECT ***REMOVED***{foreign_key_for_mva base_assoc}
  ***REMOVED***{ThinkingSphinx.unique_id_expression(offset)} AS ***REMOVED***{quote_column('id')},
  ***REMOVED***{primary_key_for_mva(end_assoc)} AS ***REMOVED***{quote_column(unique_name)}
FROM ***REMOVED***{quote_table_name base_assoc.table} ***REMOVED***{association_joins}
      SQL
    end
    
    def query_clause
      foreign_key = foreign_key_for_mva base_association_for_mva
      "WHERE ***REMOVED***{foreign_key} >= $start AND ***REMOVED***{foreign_key} <= $end"
    end
    
    def query_delta
      foreign_key = foreign_key_for_mva base_association_for_mva
      <<-SQL
***REMOVED***{foreign_key} IN (SELECT ***REMOVED***{quote_column model.primary_key}
FROM ***REMOVED***{model.quoted_table_name}
WHERE ***REMOVED***{@source.index.delta_object.clause(model, true)})
      SQL
    end
    
    def range_query
      assoc       = base_association_for_mva
      foreign_key = foreign_key_for_mva assoc
      "SELECT MIN(***REMOVED***{foreign_key}), MAX(***REMOVED***{foreign_key}) FROM ***REMOVED***{quote_table_name assoc.table}"
    end
    
    def primary_key_for_mva(assoc)
      quote_with_table(
        assoc.table, assoc.primary_key_from_reflection || columns.first.__name
      )
    end
    
    def foreign_key_for_mva(assoc)
      quote_with_table assoc.table, assoc.reflection.primary_key_name
    end
    
    def end_association_for_mva
      @association_for_mva ||= associations[columns.first].detect { |assoc|
        assoc.has_column?(columns.first.__name)
      }
    end
    
    def base_association_for_mva
      @first_association_for_mva ||= begin
        assoc = end_association_for_mva
        while !assoc.parent.nil?
          assoc = assoc.parent
        end
        
        assoc
      end
    end
    
    def association_joins
      joins = []
      assoc = end_association_for_mva
      while assoc != base_association_for_mva
        joins << assoc.to_sql
        assoc = assoc.parent
      end
      
      joins.join(' ')
    end
    
    def is_many_ints?
      concat_ws? && all_ints?
    end
    
    def is_many_datetimes?
      is_many? && all_datetimes?
    end
    
    def is_many_strings?
      is_many? && all_strings?
    end
       
    def translated_type_from_database
      case type_from_db = type_from_database
      when :integer
        integer_type_from_db
      when :datetime, :string, :float, :boolean
        type_from_db
      when :decimal
        :float
      when :timestamp, :date
        :datetime
      else
        raise <<-MESSAGE

Cannot automatically map attribute ***REMOVED***{unique_name} in ***REMOVED***{@model.name} to an
equivalent Sphinx type (integer, float, boolean, datetime, string as ordinal).
You could try to explicitly convert the column's value in your define_index
block:
  has "CAST(column AS INT)", :type => :integer, :as => :column
        MESSAGE
      end
    end
    
    def type_from_database
      column = column_from_db
      column.nil? ? nil : column.type
    end
    
    def integer_type_from_db
      column = column_from_db
      return nil if column.nil?
      
      case column.sql_type
      when adapter.bigint_pattern
        :bigint
      else
        :integer
      end
    end
    
    def column_from_db
      klass = @associations.values.flatten.first ? 
        @associations.values.flatten.first.reflection.klass : @model
      
      klass.columns.detect { |col|
        @columns.collect { |c| c.__name.to_s }.include? col.name
      }
    end
    
    def all_of_type?(*column_types)
      @columns.all? { |col|
        klasses = @associations[col].empty? ? [@model] :
          @associations[col].collect { |assoc| assoc.reflection.klass }
        klasses.all? { |klass|
          column = klass.columns.detect { |column| column.name == col.__name.to_s }
          !column.nil? && column_types.include?(column.type)
        }
      }
    end
    
    def sphinx_value(value)
      case value
      when TrueClass
        1
      when FalseClass, NilClass
        0
      when Time
        value.to_i
      when Date
        value.to_time.to_i
      when String
        value.to_crc32
      else
        value
      end
    end
  end
end
